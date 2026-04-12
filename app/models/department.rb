class Department < ApplicationRecord
  include AuditLoggable

  belongs_to :faculty
  has_many :professors, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :department_courses, dependent: :destroy
  has_many :courses, through: :department_courses
  has_many :student_department_histories, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true
end
