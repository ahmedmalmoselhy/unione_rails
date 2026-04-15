class GroupProject < ApplicationRecord
  belongs_to :section
  belongs_to :created_by_user, class_name: 'User', optional: true
  has_many :group_project_members, dependent: :destroy
  has_many :students, through: :group_project_members

  validates :title, presence: true
  validates :max_members, numericality: { greater_than: 0, only_integer: true }

  scope :active, -> { where(is_active: true) }

  def current_members_count
    group_project_members.count
  end

  def full?
    current_members_count >= max_members
  end

  def add_student(student)
    return false if full?
    return false if students.include?(student)

    group_project_members.create(student: student, joined_at: Time.current)
  end

  def remove_student(student)
    group_project_members.find_by(student: student)&.destroy
  end
end
