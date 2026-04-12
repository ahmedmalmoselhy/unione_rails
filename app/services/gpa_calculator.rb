class GpaCalculator
  GRADE_POINTS = {
    'A' => 4.0, 'A-' => 3.7, 'B+' => 3.3, 'B' => 3.0,
    'B-' => 2.7, 'C+' => 2.3, 'C' => 2.0, 'C-' => 1.7,
    'D+' => 1.3, 'D' => 1.0, 'F' => 0.0
  }.freeze

  def initialize(student)
    @student = student
  end

  # Calculate GPA for a specific academic term
  def calculate_term_gpa(term_id)
    grades = Grade.joins(enrollment: :academic_term)
                  .where(enrollments: { student_id: @student.id, academic_term_id: term_id })
                  .where.not(letter_grade: nil)

    return 0.0 if grades.empty?

    total_points = 0.0
    total_credits = 0

    grades.each do |grade|
      course = grade.enrollment.section.course
      points = GRADE_POINTS[grade.letter_grade]
      next unless points

      total_points += points * course.credit_hours
      total_credits += course.credit_hours
    end

    return 0.0 if total_credits.zero?

    (total_points / total_credits).round(2)
  end

  # Calculate cumulative GPA across all terms
  def calculate_cumulative_gpa
    grades = Grade.joins(enrollment: :section)
                  .where(enrollments: { student_id: @student.id })
                  .where.not(letter_grade: nil)

    return 0.0 if grades.empty?

    total_points = 0.0
    total_credits = 0

    grades.each do |grade|
      course = grade.enrollment.section.course
      points = GRADE_POINTS[grade.letter_grade]
      next unless points

      total_points += points * course.credit_hours
      total_credits += course.credit_hours
    end

    return 0.0 if total_credits.zero?

    (total_points / total_credits).round(2)
  end

  # Calculate credit hours completed
  def credit_hours_completed
    Grade.joins(enrollment: :section)
         .where(enrollments: { student_id: @student.id })
         .where.not(letter_grade: nil)
         .joins(enrollment: { section: :course })
         .sum('courses.credit_hours')
  end

  # Determine academic standing based on GPA
  def academic_standing(gpa)
    case gpa
    when 3.5..4.0 then 'good'
    when 2.0..3.49 then 'probation'
    else 'suspension'
    end
  end
end
