module Types
  class RoleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
  end
end
