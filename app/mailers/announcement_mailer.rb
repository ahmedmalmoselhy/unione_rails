class AnnouncementMailer < ApplicationMailer
  default from: 'announcements@unione.com'

  def new_announcement(user, announcement)
    @user = user
    @announcement = announcement
    
    mail(
      to: @user.email,
      subject: "Announcement: #{@announcement.title}"
    )
  end
end
