class TranscriptGenerator
  def initialize(student)
    @student = student
  end

  # Generate transcript data as a structured hash
  def generate
    {
      student: student_info,
      academic_terms: term_grades,
      cumulative_gpa: cumulative_gpa,
      credit_hours_completed: credit_hours_completed,
      academic_standing: @student.academic_standing,
      generated_at: DateTime.current
    }
  end

  private

  def student_info
    {
      student_number: @student.student_number,
      name: @student.user.full_name,
      faculty: @student.faculty.name,
      department: @student.department.name,
      enrolled_at: @student.enrolled_at,
      graduated_at: @student.graduated_at
    }
  end

  def term_grades
    enrollments = @student.enrollments
                          .includes(section: { course: :professor })
                          .includes(:grade, :academic_term)
                          .order('academic_terms.start_date DESC')

    enrollments.group_by(&:academic_term).map do |term, term_enrollments|
      {
        term: term.name,
        start_date: term.start_date,
        end_date: term.end_date,
        gpa: term_gpa_for(term),
        courses: term_enrollments.map do |enrollment|
          {
            code: enrollment.section.course.code,
            name: enrollment.section.course.name,
            credit_hours: enrollment.section.course.credit_hours,
            grade: enrollment.grade&.letter_grade || 'In Progress',
            points: enrollment.grade&.points
          }
        end
      }
    end
  end

  def term_gpa_for(term)
    StudentTermGpa.find_by(student: @student, academic_term: term)&.gpa
  end

  def cumulative_gpa
    GpaCalculator.new(@student).calculate_cumulative_gpa
  end

  def credit_hours_completed
    GpaCalculator.new(@student).credit_hours_completed
  end
end
