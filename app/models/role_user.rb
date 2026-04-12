class RoleUser < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :scope_entity, polymorphic: true, optional: true

  validates :user_id, uniqueness: { scope: :role_id, message: 'already has this role' }
end
