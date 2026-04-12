class SectionAnnouncement < ApplicationRecord
  belongs_to :section
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true
end
