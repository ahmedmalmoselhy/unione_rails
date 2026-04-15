class GroupProjectMember < ApplicationRecord
  belongs_to :group_project
  belongs_to :student

  validates :student_id, uniqueness: { scope: :group_project_id, message: 'is already in this group project' }

  before_create :set_joined_at

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end
end
