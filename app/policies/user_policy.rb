class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin')
  end

  def show?
    user.admin? || user == record || user.has_role?('faculty_admin')
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user == record
  end

  def destroy?
    user.admin?
  end

  def assign_role?
    user.admin?
  end

  def remove_role?
    user.admin?
  end

  def activate?
    user.admin?
  end

  def deactivate?
    user.admin?
  end

  def statistics?
    user.admin? || user.has_role?('faculty_admin')
  end
end
