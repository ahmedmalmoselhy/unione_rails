module Types
  class AcademicTermType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :registration_start, GraphQL::Types::ISO8601Date, null: false
    field :registration_end, GraphQL::Types::ISO8601Date, null: false
    field :is_active, Boolean, null: false
  end
end
