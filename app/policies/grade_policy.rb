class GradePolicy < ApplicationPolicy
  def show?
    user.student? && record.enrollment.student.user == user || 
    user.professor? && grade_belongs_to_professor? || 
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

  private

  def grade_belongs_to_professor?
    section = record.enrollment.section
    section.professor.user == user
  end
end
