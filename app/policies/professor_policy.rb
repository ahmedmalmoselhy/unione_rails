class ProfessorPolicy < ApplicationPolicy
  def index?
    user.admin? || user.has_role?('department_admin')
  end

  def show?
    user.admin? || user.professor? && record.user == user
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user.professor? && record.user == user
  end

  def destroy?
    user.admin?
  end

  def sections?
    user.professor? && record.user == user || user.admin?
  end

  def schedule?
    user.professor? && record.user == user || user.admin?
  end

  def grades?
    user.admin?
  end

  def submit_grades?
    user.admin?
  end

  def attendance?
    user.admin?
  end

  def create_attendance?
    user.admin?
  end

  def announcements?
    user.admin?
  end

  def create_announcement?
    user.admin?
  end
end
