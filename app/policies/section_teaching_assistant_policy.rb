class SectionTeachingAssistantPolicy < ApplicationPolicy
  def index?
    user.admin? || user.faculty_admin? || user.department_admin?
  end

  def create?
    user.admin? || user.faculty_admin? || user.department_admin?
  end

  def destroy?
    user.admin? || user.faculty_admin? || user.department_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.faculty_admin?
        scope.joins(section: { course: :department })
             .where(departments: { faculty_id: user.faculty_admin_faculty_ids })
      elsif user.department_admin?
        scope.joins(:section)
             .where(sections: { department_id: user.department_admin_department_ids })
      else
        scope.none
      end
    end
  end
end
