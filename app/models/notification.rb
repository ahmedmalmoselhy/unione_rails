class Notification < ApplicationRecord
  belongs_to :user

  validates :notifiable_type, presence: true
  validates :notifiable_id, presence: true
  validates :type, presence: true
end
