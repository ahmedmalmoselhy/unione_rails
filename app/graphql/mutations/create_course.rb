module Mutations
  class CreateCourse < BaseMutation
    argument :code, String, required: true
    argument :name, String, required: true
    argument :description, String, required: false
    argument :credit_hours, Integer, required: true
    argument :lecture_hours, Integer, required: true
    argument :lab_hours, Integer, required: true
    argument :level, Integer, required: true
    argument :department_id, ID, required: true

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      require_authenticated_user!
      
      # Basic check for admin role if possible, but keeping it simple for now
      # unless current_user.admin?
      #   return { course: nil, errors: ["Admin access required"] }
      # end

      course = Course.new(args)

      if course.save
        { course: course, errors: [] }
      else
        { course: nil, errors: course.errors.full_messages }
      end
    end
  end
end
