module Api
  module Professor
    class SectionsController < BaseController
      before_action :set_professor

      def index
        @sections = @professor.sections
                                .includes(:course, :academic_term)
                                .order('courses.code')
        
        if params[:term_id]
          @sections = @sections.where(academic_term_id: params[:term_id])
        end

        if params[:status] == 'current'
          active_term = AcademicTerm.find_by(is_active: true)
          @sections = @sections.where(academic_term_id: active_term.id) if active_term
        end

        render json: {
          success: true,
          data: {
            sections: @sections.map { |section| section_json(section) }
          }
        }, status: :ok
      end

      def show
        @section = @professor.sections.find(params[:id])

        render json: {
          success: true,
          data: {
            section: section_json(@section),
            students_count: @section.enrollments.active.count
          }
        }, status: :ok
      end

      def students
        @section = @professor.sections.find(params[:id])
        
        @students = @section.enrollments
                           .includes(student: [:user, :department])
                           .where(status: :active)
                           .order('users.last_name, users.first_name')

        render json: {
          success: true,
          data: {
            section: {
              id: @section.id,
              course_code: @section.course.code,
              course_name: @section.course.name
            },
            students: @students.map do |enrollment|
              student = enrollment.student
              {
                enrollment_id: enrollment.id,
                student: {
                  id: student.id,
                  student_number: student.student_number,
                  name: student.user.full_name,
                  email: student.user.email,
                  department: student.department.name
                },
                enrolled_at: enrollment.registered_at
              }
            end
          }
        }, status: :ok
      end

      def schedule
        @sections = @professor.sections
                              .includes(:course, :academic_term)
                              .where(academic_term_id: params[:term_id])

        schedule_data = @sections.map do |section|
          {
            section_id: section.id,
            course_code: section.course.code,
            course_name: section.course.name,
            schedule: section.schedule,
            location: section.schedule['location'],
            days: section.schedule['days'] || [],
            start_time: section.schedule['start_time'],
            end_time: section.schedule['end_time']
          }
        end

        render json: {
          success: true,
          data: {
            schedule: schedule_data
          }
        }, status: :ok
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

      def section_json(section)
        {
          id: section.id,
          course: {
            code: section.course.code,
            name: section.course.name,
            credit_hours: section.course.credit_hours
          },
          academic_term: {
            id: section.academic_term.id,
            name: section.academic_term.name,
            is_active: section.academic_term.is_active
          },
          semester: section.semester,
          capacity: section.capacity,
          enrolled_count: section.enrollments.active.count,
          schedule: section.schedule,
          created_at: section.created_at,
          updated_at: section.updated_at
        }
      end
    end
  end
end
