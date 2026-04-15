module Types
  class CourseType < BaseObject
    field :id, ID, null: false
    field :code, String, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :credit_hours, Integer, null: false
    field :lecture_hours, Integer, null: false
    field :lab_hours, Integer, null: false
    field :level, Integer, null: false
    field :is_active, Boolean, null: false
    field :sections, [Types::SectionType], null: false do
      argument :limit, Integer, required: false, default_value: 20
    end

    def sections(limit: 20)
      object.sections.includes(:course, :professor, :academic_term).limit(limit)
    end
  end
end
