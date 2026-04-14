module Api
  module Admin
    module V1
      class SectionTeachingAssistantsController < Api::V1::BaseController
        before_action :set_section

        def index
          @tas = SectionTeachingAssistant.where(section: @section)
                                         .includes(:professor, :assigned_by)

          render json: {
            success: true,
            data: {
              teaching_assistants: @tas.map { |ta| ta_json(ta) }
            }
          }, status: :ok
        end

        def create
          professor = Professor.find(params[:professor_id])

          ta = SectionTeachingAssistant.create!(
            section: @section,
            professor: professor,
            assigned_by: current_user
          )

          render json: {
            success: true,
            data: { teaching_assistant: ta_json(ta) },
            message: 'Teaching assistant assigned successfully'
          }, status: :created
        rescue ActiveRecord::RecordNotUnique
          render json: {
            success: false,
            error: 'Professor is already a TA for this section'
          }, status: :unprocessable_entity
        end

        def destroy
          ta = SectionTeachingAssistant.find(params[:id])
          ta.destroy!

          render json: {
            success: true,
            message: 'Teaching assistant removed successfully'
          }, status: :ok
        end

        private

        def set_section
          @section = Section.find(params[:section_id])
        end

        def ta_json(ta)
          {
            id: ta.id,
            section_id: ta.section_id,
            professor: {
              id: ta.professor.id,
              name: ta.professor.user.full_name,
              staff_number: ta.professor.staff_number
            },
            assigned_by: ta.assigned_by&.full_name,
            assigned_at: ta.created_at
          }
        end
      end
    end
  end
end
