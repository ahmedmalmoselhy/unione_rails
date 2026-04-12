class Grade < ApplicationRecord
  belongs_to :enrollment

  enum status: { complete: 0, incomplete: 1 }

  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
