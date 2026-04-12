class SendGradeNotificationJob < ApplicationJob
  queue_as :default

  def perform(grade_id)
    grade = Grade.find(grade_id)
    
    NotificationBroadcastService.grade_submitted(grade)
    GradeMailer.grade_posted(grade).deliver_now
  end
end
