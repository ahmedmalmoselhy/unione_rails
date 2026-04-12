class AttendanceSessionPolicy < ApplicationPolicy
  def index?
    user.professor? || user.admin? || user.student?
  end

  def show?
    user.professor? || user.admin? || user.student?
  end

  def create?
    user.professor? || user.admin?
  end

  def update?
    user.professor? || user.admin?
  end

  def destroy?
    user.admin?
  end
end
