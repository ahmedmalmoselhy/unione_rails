class AcademicTerm < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :student_term_gpas, dependent: :destroy
  has_many :enrollment_waitlists, dependent: :destroy

  validates :name, presence: true
  validates :start_date, :end_date, presence: true
end
