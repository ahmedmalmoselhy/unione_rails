module Api
  module Professor
    class GradesController < BaseController
      before_action :set_professor
      before_action :set_section

      def index
        authorize @section, :grades?

        @grades = Grade.joins(enrollment: :section)
                       .where(enrollments: { section_id: @section.id })
                       .includes(enrollment: { student: :user })
                       .order('users.last_name, users.first_name')

        render json: {
          success: true,
          data: {
            section: {
              id: @section.id,
              course_code: @section.course.code,
              course_name: @section.course.name
            },
            grades: @grades.map { |grade| grade_json(grade) }
          }
        }, status: :ok
      end

      def create
        authorize @section, :submit_grades?

        # Bulk grade submission
        grades_data = params[:grades] || []
        results = { success: 0, failed: 0, errors: [] }

        grades_data.each do |grade_params|
          enrollment = @section.enrollments.find_by(id: grade_params[:enrollment_id])
          next unless enrollment

          grade = enrollment.grade || Grade.new(enrollment: enrollment)
          previous_grade = grade.letter_grade
          
          if grade.update(
            points: grade_params[:points],
            letter_grade: grade_params[:letter_grade],
            status: grade_params[:status] || 'complete'
          )
            # Send notification if it's a new grade
            if previous_grade.nil? && grade.letter_grade.present?
              NotificationBroadcastService.grade_submitted(grade)
              GradeMailer.grade_posted(grade).deliver_later
              WebhookTriggerService.grade_submitted(grade)
            end
            
            results[:success] += 1
          else
            results[:failed] += 1
            results[:errors] << {
              enrollment_id: grade_params[:enrollment_id],
              errors: grade.errors.full_messages
            }
          end
        end

        render json: {
          success: true,
          message: "Grades submitted: #{results[:success]} succeeded, #{results[:failed]} failed",
          data: results
        }, status: :ok
      end

      def import
        authorize @section, :submit_grades?

        unless params[:file].present?
          return render json: {
            success: false,
            error: 'No file provided'
          }, status: :unprocessable_entity
        end

        begin
          file_data = read_excel_data(params[:file])
          service = GradeImportService.new
          result = service.import_from_array(file_data, @section.id, @section.academic_term_id)

          render json: {
            success: result[:success],
            message: "Grade import completed: #{result[:imported]} imported, #{result[:failed]} failed",
            data: {
              imported: result[:imported],
              failed: result[:failed],
              errors: result[:errors]
            }
          }, status: result[:success] ? :ok : :multi_status
        rescue => e
          render json: {
            success: false,
            error: "Grade import failed: #{e.message}"
          }, status: :unprocessable_entity
        end
      end

      def update
        @grade = Grade.find(params[:id])
        authorize @grade, :update?

        if @grade.update(grade_params)
          render json: {
            success: true,
            data: {
              grade: grade_json(@grade)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @grade.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_professor
        @professor = current_user.professor
        
        unless @professor
          return render json: {
            success: false,
            error: 'User does not have a professor profile'
          }, status: :forbidden
        end
      end

      def set_section
        @section = @professor.sections.find(params[:section_id])
      end

      def grade_params
        params.require(:grade).permit(:points, :letter_grade, :status)
      end

      def read_excel_data(file)
        filepath = file.respond_to?(:tempfile) ? file.tempfile.path : file.path
        spreadsheet = Roo::Excelx.new(filepath)
        headers = spreadsheet.row(1)

        (2..spreadsheet.last_row).map do |i|
          Hash[headers.zip(spreadsheet.row(i))]
        end
      end

      def grade_json(grade)
        {
          id: grade.id,
          enrollment_id: grade.enrollment_id,
          student: {
            id: grade.enrollment.student.id,
            student_number: grade.enrollment.student.student_number,
            name: grade.enrollment.student.user.full_name
          },
          points: grade.points,
          letter_grade: grade.letter_grade,
          status: grade.status,
          created_at: grade.created_at,
          updated_at: grade.updated_at
        }
      end
    end
  end
end
