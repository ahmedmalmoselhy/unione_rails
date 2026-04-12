class AcademicTermPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin')
  end

  def show?
    user.admin? || user.has_role?('faculty_admin')
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def activate?
    user.admin?
  end

  def deactivate?
    user.admin?
  end

  def current?
    true
  end
end
