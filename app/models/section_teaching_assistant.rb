class SectionTeachingAssistant < ApplicationRecord
  belongs_to :section
  belongs_to :professor
  belongs_to :assigned_by, class_name: 'User', optional: true

  validates :section_id, uniqueness: { scope: :professor_id }

  scope :by_section, ->(section_id) { where(section_id: section_id) }
  scope :by_professor, ->(professor_id) { where(professor_id: professor_id) }
end
