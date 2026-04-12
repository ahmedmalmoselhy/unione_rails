class UniversityPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end

  def show?
    index?
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
end
