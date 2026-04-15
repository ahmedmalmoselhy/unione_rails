class StudentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('faculty_admin') || user.has_role?('department_admin')
  end

  def show?
    user.admin? || user.student? && record.user == user || department_admin_for?(record)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || department_admin_for?(record)
  end

  def destroy?
    user.admin?
  end

  def import?
    user.admin?
  end

  def import_template?
    user.admin?
  end

  def enroll?
    user.student? && record.user == user
  end

  def drop?
    user.student? && record.user == user
  end

  def grades?
    user.student? && record.user == user || user.admin?
  end

  def transcript?
    user.student? && record.user == user || user.admin?
  end

  def schedule?
    user.student? && record.user == user || user.admin?
  end

  def attendance?
    user.student? && record.user == user || user.admin?
  end

  def ratings?
    user.student? && record.user == user
  end

  private

  def department_admin_for?(student)
    user.role_users.any? do |role_user|
      role_user.role.slug == 'department_admin' && role_user.scope_id == student.department_id
    end
  end
end
