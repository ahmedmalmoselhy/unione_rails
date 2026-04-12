class Employee < ApplicationRecord
  belongs_to :user
  belongs_to :department

  validates :staff_number, presence: true, uniqueness: true
  validates :position, presence: true
end
