class UniversityVicePresident < ApplicationRecord
  belongs_to :user
  belongs_to :university
  
  validates :department, presence: true
  validates :appointed_at, presence: true
end
