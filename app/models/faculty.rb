class Faculty < ApplicationRecord
  include AuditLoggable

  belongs_to :university
  has_many :departments, dependent: :destroy
  has_many :students, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true
end
