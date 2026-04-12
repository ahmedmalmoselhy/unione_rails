class UserPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record
  end

  def update?
    user.admin? || user == record
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
