class WebhookPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || record.user == user
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin?
  end

  def deliveries?
    user.admin? || record.user == user
  end
end
