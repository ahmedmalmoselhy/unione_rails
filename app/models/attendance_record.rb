class AttendanceRecord < ApplicationRecord
  belongs_to :attendance_session
  belongs_to :student

  enum status: { present: 0, absent: 1, late: 2 }

  validates :status, presence: true
end
