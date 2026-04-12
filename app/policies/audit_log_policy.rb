class AuditLogPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def statistics?
    user.admin?
  end
end
