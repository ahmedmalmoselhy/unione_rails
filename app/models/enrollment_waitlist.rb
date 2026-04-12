class EnrollmentWaitlist < ApplicationRecord
  belongs_to :student
  belongs_to :section
  belongs_to :academic_term

  validates :position, presence: true
  validates :requested_at, presence: true
end
