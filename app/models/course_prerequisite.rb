class CoursePrerequisite < ApplicationRecord
  belongs_to :course
  belongs_to :prerequisite, class_name: 'Course'

  validates :course_id, uniqueness: { scope: :prerequisite_id }
end
