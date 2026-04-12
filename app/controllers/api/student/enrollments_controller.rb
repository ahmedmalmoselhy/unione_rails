module Api
  module Student
    class EnrollmentsController < BaseController
      before_action :set_student
      before_action :set_enrollment, only: [:destroy]

      def index
        @enrollments = @student.enrollments
                          .includes(section: [:course, :professor, :academic_term])
                          .order(created_at: :desc)
        
        if params[:status]
          @enrollments = @enrollments.where(status: params[:status])
        end

        if params[:term_id]
          @enrollments = @enrollments.where(academic_term_id: params[:term_id])
        end

        render json: {
          success: true,
          data: {
            enrollments: @enrollments.map { |e| enrollment_json(e) }
          }
        }, status: :ok
      end

      def create
        section = Section.find(params[:section_id])
        academic_term = AcademicTerm.find_by(id: params[:academic_term_id]) || AcademicTerm.find_by(is_active: true)

        unless academic_term
          return render json: {
            success: false,
            error: 'No active academic term found'
          }, status: :unprocessable_entity
        end

        enrollment_service = EnrollmentService.new
        
        if enrollment_service.enroll(@student, section, academic_term)
          enrollment = @student.enrollments.find_by(section: section, academic_term: academic_term)
          
          # Send notification
          NotificationBroadcastService.enrollment_created(enrollment)
          
          # Send email
          EnrollmentMailer.enrollment_confirmed(enrollment).deliver_later

          render json: {
            success: true,
            message: 'Successfully enrolled in course',
            data: {
              enrollment: enrollment_json(@student.enrollments.find_by(section: section, academic_term: academic_term))
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: enrollment_service.errors
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @enrollment, :destroy?

        enrollment_service = EnrollmentService.new
        
        if enrollment_service.drop(@enrollment)
          render json: {
            success: true,
            message: 'Successfully dropped course'
          }, status: :ok
        else
          render json: {
            success: false,
            errors: enrollment_service.errors
          }, status: :unprocessable_entity
        end
      end

      private

      def set_student
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end
      end

      def set_enrollment
        @enrollment = @student.enrollments.find(params[:id])
        authorize @enrollment, :show?
      end

      def enrollment_json(enrollment)
        {
          id: enrollment.id,
          student_id: enrollment.student_id,
          section: {
            id: enrollment.section.id,
            course: {
              code: enrollment.section.course.code,
              name: enrollment.section.course.name,
              credit_hours: enrollment.section.course.credit_hours
            },
            professor: {
              name: enrollment.section.professor.user.full_name
            },
            schedule: enrollment.section.schedule,
            capacity: enrollment.section.capacity,
            enrolled_count: enrollment.section.enrollments.active.count
          },
          academic_term: {
            id: enrollment.academic_term.id,
            name: enrollment.academic_term.name
          },
          status: enrollment.status,
          registered_at: enrollment.registered_at,
          dropped_at: enrollment.dropped_at,
          created_at: enrollment.created_at
        }
      end
    end
  end
end
