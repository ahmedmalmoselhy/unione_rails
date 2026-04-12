class Course < ApplicationRecord
  has_many :department_courses, dependent: :destroy
  has_many :departments, through: :department_courses
  has_many :course_prerequisites_as_course, class_name: 'CoursePrerequisite', foreign_key: 'course_id', dependent: :destroy
  has_many :course_prerequisites_as_prerequisite, class_name: 'CoursePrerequisite', foreign_key: 'prerequisite_id', dependent: :destroy
  has_many :prerequisites, through: :course_prerequisites_as_course, source: :prerequisite
  has_many :sections, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :credit_hours, presence: true, numericality: { greater_than: 0 }
end
