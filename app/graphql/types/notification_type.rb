module Types
  class NotificationType < BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :data, GraphQL::Types::JSON, null: false
    field :read_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
