class DepartmentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end

  def show?
    user.admin? || user.has_role?('faculty_admin') || department_admin_for?(record)
  end

  def create?
    user.admin? || user.has_role?('faculty_admin')
  end

  def update?
    user.admin? || department_admin_for?(record)
  end

  def destroy?
    user.admin?
  end

  private

  def department_admin_for?(department)
    user.role_users.any? do |role_user|
      role_user.role.slug == 'department_admin' && role_user.scope_id == department.id
    end
  end
end
