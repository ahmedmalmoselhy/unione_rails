module AuditLoggable
  extend ActiveSupport::Concern

  included do
    after_create :log_creation
    after_update :log_update
    after_destroy :log_destruction
  end

  private

  def log_creation
    AuditLog.create!(
      user: Current.user,
      action: 'create',
      auditable_type: self.class.name,
      auditable_id: id,
      description: "Created #{self.class.name} ##{id}",
      new_values: serializable_hash,
      ip_address: Current.ip_address
    )
  end

  def log_update
    changes_to_log = saved_changes.except('updated_at')
    
    return if changes_to_log.empty?

    AuditLog.create!(
      user: Current.user,
      action: 'update',
      auditable_type: self.class.name,
      auditable_id: id,
      description: "Updated #{self.class.name} ##{id}",
      old_values: changes_to_log.transform_values { |v| v[0] },
      new_values: changes_to_log.transform_values { |v| v[1] },
      ip_address: Current.ip_address
    )
  end

  def log_destruction
    AuditLog.create!(
      user: Current.user,
      action: 'destroy',
      auditable_type: self.class.name,
      auditable_id: id,
      description: "Destroyed #{self.class.name} ##{id}",
      old_values: serializable_hash,
      ip_address: Current.ip_address
    )
  end
end
