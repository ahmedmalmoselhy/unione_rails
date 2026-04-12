class AttendanceSession < ApplicationRecord
  belongs_to :section
  has_many :attendance_records, dependent: :destroy

  enum status: { open: 0, closed: 1, archived: 2 }

  validates :date, presence: true
  validates :session_number, presence: true
end
