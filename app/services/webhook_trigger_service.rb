class WebhookTriggerService
  EVENTS = {
    enrollment_created: 'enrollment.created',
    enrollment_dropped: 'enrollment.dropped',
    grade_submitted: 'grade.submitted',
    student_enrolled: 'student.enrolled',
    student_graduated: 'student.graduated',
    attendance_session_created: 'attendance_session.created',
    announcement_created: 'announcement.created',
    user_created: 'user.created',
    user_updated: 'user.updated'
  }.freeze

  # Trigger webhook for an event
  def self.trigger(event_name, data:)
    event = EVENTS[event_name]
    return unless event

    # Find active webhooks subscribed to this event
    webhooks = Webhook.where(is_active: true)
                      .where("events @> ?", [event].to_json)

    webhooks.each do |webhook|
      WebhookDeliveryJob.perform_later(webhook.id, event, data)
    end
  end

  # Trigger enrollment created webhook
  def self.enrollment_created(enrollment)
    trigger(:enrollment_created, data: {
      enrollment_id: enrollment.id,
      student_id: enrollment.student_id,
      section_id: enrollment.section_id,
      course_code: enrollment.section.course.code,
      status: enrollment.status,
      registered_at: enrollment.registered_at
    })
  end

  # Trigger grade submitted webhook
  def self.grade_submitted(grade)
    trigger(:grade_submitted, data: {
      grade_id: grade.id,
      enrollment_id: grade.enrollment_id,
      student_id: grade.enrollment.student_id,
      course_code: grade.enrollment.section.course.code,
      letter_grade: grade.letter_grade,
      points: grade.points
    })
  end

  # Trigger student graduated webhook
  def self.student_graduated(student)
    trigger(:student_graduated, data: {
      student_id: student.id,
      student_number: student.student_number,
      faculty: student.faculty.name,
      department: student.department.name,
      final_gpa: student.gpa,
      graduated_at: student.graduated_at
    })
  end
end
