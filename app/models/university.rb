class University < ApplicationRecord
  include AuditLoggable

  belongs_to :president, class_name: 'User', optional: true
  has_many :faculties, dependent: :destroy
  has_many :university_vice_presidents, dependent: :destroy
  has_one_attached :logo

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
