class DashboardPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end
end
