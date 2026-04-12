class GradeSubmissionService
  GRADE_POINTS = {
    'A' => 95, 'A-' => 90, 'B+' => 87, 'B' => 83,
    'B-' => 80, 'C+' => 77, 'C' => 73, 'C-' => 70,
    'D+' => 67, 'D' => 63, 'F' => 50
  }.freeze

  attr_reader :errors, :submitted_count, :failed_count

  def initialize
    @errors = []
    @submitted_count = 0
    @failed_count = 0
  end

  # Submit grades for multiple students in a section
  def submit_grades(section_id, academic_term_id, grades_data)
    section = ::Section.find(section_id)
    
    grades_data.each do |grade_data|
      submit_single_grade(section, academic_term_id, grade_data)
    end

    {
      success: @failed_count.zero?,
      submitted: @submitted_count,
      failed: @failed_count,
      errors: @errors
    }
  end

  # Submit a single grade
  def submit_single_grade(section, academic_term_id, grade_data)
    enrollment = find_enrollment(section, academic_term_id, grade_data)
    
    unless enrollment
      @errors << "Enrollment not found for student #{grade_data[:student_id]}"
      @failed_count += 1
      return false
    end

    grade = enrollment.grade || ::Grade.new(enrollment: enrollment)
    
    grade.assign_attributes(
      points: grade_data[:points],
      letter_grade: grade_data[:letter_grade],
      status: :complete
    )

    if grade.save
      @submitted_count += 1
      
      # Trigger notifications and webhooks
      SendGradeNotificationJob.perform_later(grade.id)
      WebhookTriggerService.grade_submitted(grade)
      
      # Update student GPA
      update_student_gpa(enrollment.student, academic_term_id)
      
      true
    else
      @errors << "Failed to save grade for student #{grade_data[:student_id]}: #{grade.errors.full_messages.join(', ')}"
      @failed_count += 1
      false
    end
  end

  # Calculate letter grade from points
  def self.calculate_letter_grade(points)
    case points
    when 95..100 then 'A'
    when 90..94 then 'A-'
    when 87..89 then 'B+'
    when 83..86 then 'B'
    when 80..82 then 'B-'
    when 77..79 then 'C+'
    when 73..76 then 'C'
    when 70..72 then 'C-'
    when 67..69 then 'D+'
    when 63..66 then 'D'
    else 'F'
    end
  end

  # Calculate points from letter grade
  def self.calculate_points(letter_grade)
    GRADE_POINTS[letter_grade] || 0
  end

  private

  def find_enrollment(section, academic_term_id, grade_data)
    ::Enrollment.find_by(
      student_id: grade_data[:student_id],
      section_id: section.id,
      academic_term_id: academic_term_id
    )
  end

  def update_student_gpa(student, academic_term_id)
    calculator = GpaCalculator.new(student)
    gpa = calculator.calculate_term_gpa(academic_term_id)
    credit_hours = calculator.credit_hours_completed

    ::StudentTermGpa.find_or_create_by(
      student: student,
      academic_term_id: academic_term_id
    ).update(gpa: gpa, credit_hours_completed: credit_hours)
  end
end
