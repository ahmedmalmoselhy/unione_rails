class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :section
  belongs_to :academic_term

  has_one :grade, dependent: :destroy
  has_one :course_rating, dependent: :destroy

  enum status: { active: 0, completed: 1, dropped: 2 }

  validates :registered_at, presence: true
end
