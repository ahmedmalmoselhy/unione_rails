module Types
  class StudentType < BaseObject
    field :id, ID, null: false
    field :student_number, String, null: false
    field :faculty_id, ID, null: false
    field :department_id, ID, null: false
    field :academic_year, Integer, null: false
    field :semester, Integer, null: false
    field :enrollment_status, String, null: false
    field :gpa, Float, null: true
    field :academic_standing, String, null: false
    field :user, Types::UserType, null: false

    def gpa
      object.gpa&.to_f
    end
  end
end
