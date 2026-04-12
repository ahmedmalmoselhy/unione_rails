class DepartmentCourse < ApplicationRecord
  belongs_to :department
  belongs_to :course

  validates :department_id, uniqueness: { scope: :course_id }
end
