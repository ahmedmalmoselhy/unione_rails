module Types
  class UserPayloadType < BaseObject
    field :user, Types::UserType, null: true
    field :errors, [String], null: false
  end
end
