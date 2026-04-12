class EnrollmentMailer < ApplicationMailer
  default from: 'enrollments@unione.com'

  def enrollment_confirmed(enrollment)
    @enrollment = enrollment
    @student = enrollment.student
    @course = enrollment.section.course
    @professor = enrollment.section.professor
    
    mail(
      to: @student.user.email,
      subject: "Enrollment Confirmed: #{@course.code} - #{@course.name}"
    )
  end

  def enrollment_dropped(enrollment)
    @enrollment = enrollment
    @student = enrollment.student
    @course = enrollment.section.course
    
    mail(
      to: @student.user.email,
      subject: "Course Dropped: #{@course.code} - #{@course.name}"
    )
  end

  def waitlist_position_updated(waitlist_entry)
    @waitlist_entry = waitlist_entry
    @student = waitlist_entry.student
    @course = waitlist_entry.section.course
    
    mail(
      to: @student.user.email,
      subject: "Waitlist Position Updated: #{@course.code} - Position ##{@waitlist_entry.position}"
    )
  end
end
