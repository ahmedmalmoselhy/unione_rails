class AttendanceRecordPolicy < ApplicationPolicy
  def index?
    user.student? && record.student.user == user || 
    user.professor? || 
    user.admin?
  end

  def show?
    user.student? && record.student.user == user || 
    user.professor? || 
    user.admin?
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
