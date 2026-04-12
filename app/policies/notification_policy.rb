class NotificationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.user == user || user.admin?
  end

  def destroy?
    record.user == user || user.admin?
  end

  def mark_read?
    record.user == user || user.admin?
  end

  def mark_all_read?
    true
  end
end
