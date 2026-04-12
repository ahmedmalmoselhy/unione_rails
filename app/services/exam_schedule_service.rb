class ExamScheduleService
  # Create exam schedule for a section
  def create_exam_schedule(section, exam_data)
    exam_schedule = {
      date: exam_data[:date],
      start_time: exam_data[:start_time],
      end_time: exam_data[:end_time],
      location: exam_data[:location],
      type: exam_data[:type] || 'final', # midterms or final
      notes: exam_data[:notes]
    }

    section.update(exam_schedule: exam_schedule)

    # Send notifications to students
    send_exam_notifications(section, exam_schedule)

    exam_schedule
  end

  # Get exam schedule for a section
  def get_exam_schedule(section)
    section.exam_schedule
  end

  # Publish exam schedule
  def publish_exam_schedule(section)
    return false unless section.exam_schedule.present?

    # Send notifications
    send_exam_notifications(section, section.exam_schedule)
    
    # Send email
    ExamScheduleMailer.exam_schedule_published(section, section.exam_schedule).deliver_later

    true
  end

  # Get exam schedule for student's enrolled courses
  def get_student_exam_schedule(student)
    sections = student.sections.includes(:course, :professor)
    
    exam_schedules = []
    
    sections.each do |section|
      next unless section.exam_schedule.present?

      exam_schedules << {
        section_id: section.id,
        course_code: section.course.code,
        course_name: section.course.name,
        professor: section.professor.user.full_name,
        exam: section.exam_schedule
      }
    end

    # Sort by date
    exam_schedules.sort_by { |e| e[:exam][:date] }
  end

  # Check for exam conflicts
  def check_conflicts(student)
    exams = get_student_exam_schedule(student)
    conflicts = []

    exams.each do |exam1|
      exams.each do |exam2|
        next if exam1[:section_id] == exam2[:section_id]

        # Check if same date and overlapping times
        if exam1[:exam][:date] == exam2[:exam][:date]
          if times_overlap?(exam1[:exam], exam2[:exam])
            conflicts << {
              exam1: exam1,
              exam2: exam2
            }
          end
        end
      end
    end

    conflicts.uniq { |c| [c[:exam1][:section_id], c[:exam2][:section_id]].sort }
  end

  private

  def send_exam_notifications(section, exam_schedule)
    section.students.each do |student|
      NotificationBroadcastService.broadcast_to_user(
        student.user,
        notification_type: 'ExamScheduleNotification',
        data: {
          title: 'Exam Schedule Published',
          message: "Exam for #{section.course.code} on #{exam_schedule[:date]}",
          section_id: section.id,
          course_code: section.course.code,
          exam_date: exam_schedule[:date],
          exam_time: exam_schedule[:start_time]
        },
        notifiable_type: 'Student',
        notifiable_id: student.id
      )
    end
  end

  def times_overlap?(exam1, exam2)
    return false if exam1[:start_time].blank? || exam2[:start_time].blank?

    start1 = time_to_minutes(exam1[:start_time])
    end1 = time_to_minutes(exam1[:end_time])
    start2 = time_to_minutes(exam2[:start_time])
    end2 = time_to_minutes(exam2[:end_time])

    start1 < end2 && start2 < end1
  end

  def time_to_minutes(time_str)
    return 0 if time_str.blank?
    hours, minutes = time_str.split(':').map(&:to_i)
    hours * 60 + minutes
  end
end
