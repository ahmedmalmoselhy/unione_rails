class Student < ApplicationRecord
  belongs_to :user
  belongs_to :faculty
  belongs_to :department

  has_many :enrollments, dependent: :destroy
  has_many :sections, through: :enrollments
  has_many :attendance_records, dependent: :destroy
  has_many :department_histories, class_name: 'StudentDepartmentHistory', dependent: :destroy
  has_many :term_gpas, class_name: 'StudentTermGpa', dependent: :destroy
  has_many :enrollment_waitlists, dependent: :destroy

  enum enrollment_status: { active: 0, graduated: 1, suspended: 2 }
  enum academic_standing: { excellent: 0, good: 1, probation: 2, suspension: 3 }

  validates :student_number, presence: true, uniqueness: true

  delegate :first_name, :last_name, :email, to: :user
end
