class Section < ApplicationRecord
  belongs_to :course
  belongs_to :professor
  belongs_to :academic_term

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
  has_many :attendance_sessions, dependent: :destroy
  has_many :section_announcements, dependent: :destroy
  has_many :group_projects, dependent: :destroy

  validates :capacity, numericality: { greater_than: 0 }

  # JSONB query helpers
  def self.by_location(location)
    where("schedule ->> 'location' = ?", location)
  end

  def self.by_day(day)
    where("schedule -> 'days' @> ?", [day].to_json)
  end

  def schedule_days
    schedule['days'] || []
  end

  def start_time
    schedule['start_time']
  end

  def end_time
    schedule['end_time']
  end

  def location
    schedule['location']
  end
end
