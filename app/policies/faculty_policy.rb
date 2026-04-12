class FacultyPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end

  def show?
    user.admin? || user.has_role?('faculty_admin') || faculty_admin_for?(record)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || faculty_admin_for?(record)
  end

  def destroy?
    user.admin?
  end

  private

  def faculty_admin_for?(faculty)
    user.role_users.any? do |role_user|
      role_user.role.slug == 'faculty_admin' && role_user.scope_id == faculty.id
    end
  end
end
