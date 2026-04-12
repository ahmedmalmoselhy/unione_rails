class Announcement < ApplicationRecord
  belongs_to :user
  has_many :announcement_reads, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true
end
