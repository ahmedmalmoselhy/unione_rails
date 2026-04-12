class ExamScheduleMailer < ApplicationMailer
  default from: 'exams@unione.com'

  def exam_schedule_published(section, exam_info)
    @section = section
    @exam_info = exam_info
    @students = section.students
    
    mail(
      to: @students.map(&:email),
      subject: "Exam Schedule Published: #{@section.course.code}"
    )
  end
end
