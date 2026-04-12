module Api
  module Student
    class ProfileController < BaseController
      def show
        @student = current_user.student
        authorize @student, :show?

        render json: {
          success: true,
          data: {
            student: student_json(@student)
          }
        }, status: :ok
      end

      def update
        @student = current_user.student
        authorize @student, :update?

        if @student.update(student_params)
          render json: {
            success: true,
            data: {
              student: student_json(@student)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @student.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def student_json(student)
        {
          id: student.id,
          student_number: student.student_number,
          user: {
            id: student.user.id,
            first_name: student.user.first_name,
            last_name: student.user.last_name,
            email: student.user.email,
            phone: student.user.phone,
            gender: student.user.gender,
            date_of_birth: student.user.date_of_birth
          },
          faculty: {
            id: student.faculty.id,
            name: student.faculty.name,
            code: student.faculty.code
          },
          department: {
            id: student.department.id,
            name: student.department.name,
            code: student.department.code
          },
          academic_year: student.academic_year,
          semester: student.semester,
          enrollment_status: student.enrollment_status,
          gpa: student.gpa,
          academic_standing: student.academic_standing,
          enrolled_at: student.enrolled_at,
          graduated_at: student.graduated_at,
          created_at: student.created_at,
          updated_at: student.updated_at
        }
      end

      def student_params
        params.require(:student).permit(:academic_year, :semester)
      end
    end
  end
end
