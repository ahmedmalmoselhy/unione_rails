class CourseRating < ApplicationRecord
  belongs_to :enrollment

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :enrollment_id, uniqueness: true
end
