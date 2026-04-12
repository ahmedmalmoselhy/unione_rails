class AnnouncementPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def mark_read?
    true
  end
end
