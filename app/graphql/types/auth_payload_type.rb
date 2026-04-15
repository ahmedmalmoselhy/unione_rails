module Types
  class AuthPayloadType < BaseObject
    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [String], null: false
  end
end
