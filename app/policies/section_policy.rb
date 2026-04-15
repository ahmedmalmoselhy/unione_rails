class SectionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user_can_view_section?
  end

  def create?
    user.admin? || user.has_role?('department_admin')
  end

  def update?
    user.admin? || user.has_role?('department_admin')
  end

  def destroy?
    user.admin?
  end

  def students?
    user.professor? && record.professor.user == user || user.admin?
  end

  def grades?
    user.professor? && record.professor.user == user || user.admin? || user.student?
  end

  def submit_grades?
    user.professor? && record.professor.user == user || user.admin?
  end

  def attendance?
    user.professor? && record.professor.user == user || user.admin?
  end

  def create_attendance?
    user.professor? && record.professor.user == user || user.admin?
  end

  def announcements?
    true
  end

  def create_announcement?
    user.professor? && record.professor.user == user || user.admin?
  end

  def import_grades?
    user.admin?
  end

  def grades_import_template?
    user.admin?
  end

  private

  def user_can_view_section?
    return true if user.admin? || user.has_role?('department_admin')
    return true if user.professor? && record.professor.user == user
    return true if user.student? && record.students.include?(user.student)

    false
  end
end
