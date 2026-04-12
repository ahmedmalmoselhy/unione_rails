class EmployeePolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('department_admin')
  end

  def show?
    user.admin? || user == record.user || user.has_role?('department_admin')
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user == record.user
  end

  def destroy?
    user.admin?
  end
end
