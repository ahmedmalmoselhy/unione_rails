module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :full_name, String, null: false
    field :phone, String, null: true
    field :is_active, Boolean, null: false
    field :role_slugs, [String], null: false
    field :student, Types::StudentType, null: true
    field :professor, Types::ProfessorType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def role_slugs
      object.role_slugs
    end
  end
end
