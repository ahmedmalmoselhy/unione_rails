class Professor < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_many :sections, dependent: :destroy

  validates :staff_number, presence: true, uniqueness: true
  validates :academic_rank, presence: true
end
