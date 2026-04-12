class NotificationMailer < ApplicationMailer
  default from: 'notifications@unione.com'

  def new_notification(user, notification)
    @user = user
    @notification = notification
    @data = notification.data
    
    mail(
      to: @user.email,
      subject: "Notification: #{@data['title'] || 'New Notification'}"
    )
  end

  def notification_digest(user, notifications)
    @user = user
    @notifications = notifications
    @count = notifications.count
    
    mail(
      to: @user.email,
      subject: "You have #{@count} new notification#{@count > 1 ? 's' : ''}"
    )
  end
end
