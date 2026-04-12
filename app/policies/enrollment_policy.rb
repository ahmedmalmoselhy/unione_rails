class EnrollmentPolicy < ApplicationPolicy
  def index?
    user.student? && record.student.user == user || user.admin?
  end

  def show?
    user.student? && record.student.user == user || user.admin?
  end

  def create?
    user.student?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.student? && record.student.user == user
  end
end
