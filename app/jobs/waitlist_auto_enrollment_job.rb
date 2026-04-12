class WaitlistAutoEnrollmentJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Process waitlist for a specific section
  def perform(section_id, academic_term_id)
    section = Section.find(section_id)
    academic_term = AcademicTerm.find(academic_term_id)

    return unless section.enrollments.active.count < section.capacity

    # Get next student from waitlist
    waitlist_entry = EnrollmentWaitlist.where(section: section, academic_term: academic_term)
                                       .order(position: :asc)
                                       .first

    return unless waitlist_entry

    student = waitlist_entry.student
    
    # Verify student still wants the seat (within time window)
    enrollment_service = EnrollmentService.new
    
    if enrollment_service.can_enroll?(student, section, academic_term)
      # Enroll the student
      if enrollment_service.enroll(student, section, academic_term)
        # Remove from waitlist
        waitlist_entry.destroy
        
        # Update positions for remaining students
        update_waitlist_positions(section, academic_term)
        
        # Send notification to student
        Notification.create!(
          user: student.user,
          notifiable_type: 'Student',
          notifiable_id: student.id,
          type: 'EnrollmentNotification',
          data: {
            message: "You've been enrolled in #{section.course.code} from the waitlist",
            section_id: section.id,
            action: 'auto_enrolled'
          }
        )
        
        Rails.logger.info "Auto-enrolled student #{student.student_number} in section #{section.id}"
      end
    else
      # Student can't be enrolled, remove from waitlist and try next
      Rails.logger.warn "Student #{student.student_number} on waitlist can't be enrolled: #{enrollment_service.errors.join(', ')}"
      waitlist_entry.destroy
      update_waitlist_positions(section, academic_term)
      
      # Try next student recursively
      WaitlistAutoEnrollmentJob.perform_later(section_id, academic_term_id)
    end
  end

  # Process all waitlists for sections with available capacity
  def self.process_all_waitlists
    sections_with_capacity = Section.joins(:academic_term)
                                    .where('sections.capacity > (SELECT COUNT(*) FROM enrollments WHERE enrollments.section_id = sections.id AND enrollments.status = 0)')
                                    .where(academic_terms: { is_active: true })

    sections_with_capacity.each do |section|
      waitlist_count = EnrollmentWaitlist.where(section: section, academic_term: section.academic_term).count
      if waitlist_count > 0
        WaitlistAutoEnrollmentJob.perform_later(section.id, section.academic_term_id)
      end
    end
  end

  private

  def update_waitlist_positions(section, academic_term)
    waitlist_entries = EnrollmentWaitlist.where(section: section, academic_term: academic_term)
                                         .order(position: :asc)
    
    waitlist_entries.each_with_index do |entry, index|
      entry.update(position: index + 1) if entry.position != (index + 1)
    end
  end
end
