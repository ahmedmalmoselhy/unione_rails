module Types
  class ProfessorType < BaseObject
    field :id, ID, null: false
    field :staff_number, String, null: false
    field :department_id, ID, null: false
    field :specialization, String, null: true
    field :academic_rank, String, null: false
    field :office_location, String, null: true
    field :user, Types::UserType, null: false
  end
end
