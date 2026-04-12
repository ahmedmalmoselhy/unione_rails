class StudentTermGpa < ApplicationRecord
  belongs_to :student
  belongs_to :academic_term

  validates :gpa, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 4.0 }, allow_nil: true
end
