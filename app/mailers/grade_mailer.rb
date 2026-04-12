class GradeMailer < ApplicationMailer
  default from: 'grades@unione.com'

  def grade_posted(grade)
    @grade = grade
    @student = grade.enrollment.student
    @course = grade.enrollment.section.course
    @professor = grade.enrollment.section.professor
    
    mail(
      to: @student.user.email,
      subject: "Grade Posted: #{@course.code} - #{@grade.letter_grade}"
    )
  end

  def grade_updated(grade, previous_grade)
    @grade = grade
    @previous_grade = previous_grade
    @student = grade.enrollment.student
    @course = grade.enrollment.section.course
    
    mail(
      to: @student.user.email,
      subject: "Grade Updated: #{@course.code}"
    )
  end
end
