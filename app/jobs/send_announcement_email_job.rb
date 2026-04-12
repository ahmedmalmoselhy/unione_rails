class SendAnnouncementEmailJob < ApplicationJob
  queue_as :mailers

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)
    
    User.active.find_each do |user|
      AnnouncementMailer.new_announcement(user, announcement).deliver_now
    end
  end
end
