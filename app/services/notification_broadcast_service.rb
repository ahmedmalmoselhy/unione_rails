class NotificationBroadcastService
  # Broadcast notification to a specific user
  def self.broadcast_to_user(user, notification_type:, data:, notifiable_type: 'User', notifiable_id: nil)
    notification = Notification.create!(
      user: user,
      notifiable_type: notifiable_type,
      notifiable_id: notifiable_id || user.id,
      type: notification_type,
      data: data
    )

    # Broadcast via ActionCable
    NotificationChannel.broadcast_to(
      user,
      {
        type: 'new_notification',
        notification: notification_json(notification)
      }
    )

    notification
  end

  # Broadcast to multiple users
  def self.broadcast_to_users(users, notification_type:, data:, notifiable_type: 'User', notifiable_id: nil)
    notifications = []
    
    users.each do |user|
      notifications << broadcast_to_user(
        user,
        notification_type: notification_type,
        data: data,
        notifiable_type: notifiable_type,
        notifiable_id: notifiable_id
      )
    end

    notifications
  end

  # Broadcast enrollment notification
  def self.enrollment_created(enrollment)
    broadcast_to_user(
      enrollment.student.user,
      notification_type: 'EnrollmentNotification',
      data: {
        title: 'Enrollment Confirmed',
        message: "You've been enrolled in #{enrollment.section.course.code} - #{enrollment.section.course.name}",
        section_id: enrollment.section.id,
        course_code: enrollment.section.course.code
      },
      notifiable_type: 'Student',
      notifiable_id: enrollment.student.id
    )
  end

  # Broadcast grade submitted notification
  def self.grade_submitted(grade)
    broadcast_to_user(
      grade.enrollment.student.user,
      notification_type: 'GradeNotification',
      data: {
        title: 'Grade Posted',
        message: "Your grade for #{grade.enrollment.section.course.code} has been posted: #{grade.letter_grade}",
        grade_id: grade.id,
        course_code: grade.enrollment.section.course.code,
        letter_grade: grade.letter_grade,
        points: grade.points
      },
      notifiable_type: 'Student',
      notifiable_id: grade.enrollment.student.id
    )
  end

  # Broadcast announcement notification
  def self.announcement_created(announcement)
    # Broadcast to all users
    User.active.find_each do |user|
      broadcast_to_user(
        user,
        notification_type: 'AnnouncementNotification',
        data: {
          title: 'New Announcement',
          message: announcement.title,
          announcement_id: announcement.id
        },
        notifiable_type: 'User',
        notifiable_id: user.id
      )
    end
  end

  # Broadcast attendance session created
  def self.attendance_session_created(session)
    session.section.students.each do |student|
      broadcast_to_user(
        student.user,
        notification_type: 'AttendanceNotification',
        data: {
          title: 'Attendance Session Opened',
          message: "A new attendance session is open for #{session.section.course.code}",
          session_id: session.id,
          course_code: session.section.course.code,
          date: session.date
        },
        notifiable_type: 'Student',
        notifiable_id: student.id
      )
    end
  end

  private

  def self.notification_json(notification)
    {
      id: notification.id,
      user_id: notification.user_id,
      type: notification.type,
      data: notification.data,
      read_at: notification.read_at,
      created_at: notification.created_at
    }
  end
end
