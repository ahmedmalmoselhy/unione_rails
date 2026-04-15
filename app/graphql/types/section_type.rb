module Types
  class SectionType < BaseObject
    field :id, ID, null: false
    field :semester, Integer, null: false
    field :capacity, Integer, null: false
    field :schedule, GraphQL::Types::JSON, null: true
    field :course, Types::CourseType, null: false
    field :professor, Types::ProfessorType, null: false
    field :academic_term, Types::AcademicTermType, null: false
    field :enrolled_count, Integer, null: false

    def enrolled_count
      object.enrollments.active.count
    end
  end
end
