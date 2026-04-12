class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  def mark_as_read(data)
    notification = current_user.notifications.find_by(id: data['notification_id'])
    
    if notification
      notification.update(read_at: DateTime.current)
      
      ActionCable.server.broadcast_to(
        current_user,
        {
          type: 'notification_read',
          notification_id: notification.id,
          read_at: notification.read_at
        }
      )
    end
  end
end
