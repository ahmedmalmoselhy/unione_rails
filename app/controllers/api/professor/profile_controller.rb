module Api
  module Professor
    class ProfileController < BaseController
      def show
        @professor = current_user.professor
        
        unless @professor
          return render json: {
            success: false,
            error: 'User does not have a professor profile'
          }, status: :forbidden
        end

        authorize @professor, :show?

        render json: {
          success: true,
          data: {
            professor: professor_json(@professor)
          }
        }, status: :ok
      end

      def update
        @professor = current_user.professor
        
        unless @professor
          return render json: {
            success: false,
            error: 'User does not have a professor profile'
          }, status: :forbidden
        end

        authorize @professor, :update?

        if @professor.update(professor_params)
          render json: {
            success: true,
            data: {
              professor: professor_json(@professor)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @professor.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def professor_json(professor)
        {
          id: professor.id,
          staff_number: professor.staff_number,
          user: {
            id: professor.user.id,
            first_name: professor.user.first_name,
            last_name: professor.user.last_name,
            email: professor.user.email,
            phone: professor.user.phone,
            gender: professor.user.gender,
            date_of_birth: professor.user.date_of_birth
          },
          department: {
            id: professor.department.id,
            name: professor.department.name,
            code: professor.department.code,
            faculty: {
              id: professor.department.faculty.id,
              name: professor.department.faculty.name
            }
          },
          specialization: professor.specialization,
          academic_rank: professor.academic_rank,
          office_location: professor.office_location,
          hired_at: professor.hired_at,
          created_at: professor.created_at,
          updated_at: professor.updated_at
        }
      end

      def professor_params
        params.require(:professor).permit(:specialization, :office_location)
      end
    end
  end
end
