class StudentDepartmentHistory < ApplicationRecord
  belongs_to :student
  belongs_to :department

  validates :academic_year, presence: true
  validates :semester, presence: true
end
