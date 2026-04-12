class EnrollmentService
  attr_reader :errors

  def initialize
    @errors = []
  end

  # Enroll a student in a section
  def enroll(student, section, academic_term)
    @errors = []

    unless valid_enrollment?(student, section, academic_term)
      return false
    end

    enrollment = Enrollment.new(
      student: student,
      section: section,
      academic_term: academic_term,
      status: :active,
      registered_at: DateTime.current
    )

    if enrollment.save
      update_student_term_gpa(student, academic_term)
      true
    else
      @errors = enrollment.errors.full_messages
      false
    end
  end

  # Drop a student from a section
  def drop(enrollment)
    @errors = []

    unless enrollment.active?
      @errors << 'Enrollment is not active'
      return false
    end

    term = enrollment.academic_term
    if DateTime.current > term.registration_end
      @errors << 'Drop deadline has passed'
      return false
    end

    enrollment.update(status: :dropped, dropped_at: DateTime.current)
  end

  # Check if student can enroll in a section
  def can_enroll?(student, section, academic_term)
    @errors = []

    # Check capacity
    if section.enrollments.active.count >= section.capacity
      @errors << 'Section is full'
      return false
    end

    # Check for time conflicts
    if has_time_conflict?(student, section)
      @errors << 'Time conflict with existing enrollment'
      return false
    end

    # Check prerequisites
    unless prerequisites_met?(student, section.course)
      @errors << 'Prerequisites not met'
      return false
    end

    # Check for duplicate enrollment
    if already_enrolled?(student, section)
      @errors << 'Already enrolled in this section'
      return false
    end

    true
  end

  private

  def valid_enrollment?(student, section, academic_term)
    can_enroll?(student, section, academic_term)
  end

  def has_time_conflict?(student, section)
    student_sections = Section.joins(:enrollments)
                             .where(enrollments: { student_id: student.id, status: :active })
                             .where.not(id: section.id)

    student_sections.any? do |existing_section|
      times_overlap?(section.schedule, existing_section.schedule)
    end
  end

  def times_overlap?(schedule1, schedule2)
    return false if schedule1.blank? || schedule2.blank?

    days1 = schedule1['days'] || []
    days2 = schedule2['days'] || []

    return false if (days1 & days2).empty?

    start1 = schedule1['start_time']
    end1 = schedule1['end_time']
    start2 = schedule2['start_time']
    end2 = schedule2['end_time']

    return false if start1.blank? || end1.blank? || start2.blank? || end2.blank?

    # Convert times to minutes for comparison
    start1_min = time_to_minutes(start1)
    end1_min = time_to_minutes(end1)
    start2_min = time_to_minutes(start2)
    end2_min = time_to_minutes(end2)

    start1_min < end2_min && start2_min < end1_min
  end

  def time_to_minutes(time_str)
    hours, minutes = time_str.split(':').map(&:to_i)
    hours * 60 + minutes
  end

  def prerequisites_met?(student, course)
    course.prerequisites.each do |prerequisite|
      unless student_has_prerequisite?(student, prerequisite)
        return false
      end
    end
    true
  end

  def student_has_prerequisite?(student, prerequisite)
    Enrollment.joins(section: :course)
              .where(student_id: student.id)
              .where(courses: { id: prerequisite.id })
              .joins(:grades)
              .where.not(grades: { letter_grade: nil })
              .where.not(grades: { letter_grade: 'F' })
              .exists?
  end

  def already_enrolled?(student, section)
    Enrollment.where(student_id: student.id, section_id: section.id, status: :active).exists?
  end

  def update_student_term_gpa(student, academic_term)
    calculator = GpaCalculator.new(student)
    gpa = calculator.calculate_term_gpa(academic_term.id)
    credit_hours = calculator.credit_hours_completed

    StudentTermGpa.find_or_create_by(
      student: student,
      academic_term: academic_term
    ).update(gpa: gpa, credit_hours_completed: credit_hours)
  end
end
