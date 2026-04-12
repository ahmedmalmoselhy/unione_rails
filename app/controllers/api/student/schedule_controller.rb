module Api
  module Student
    class ScheduleController < BaseController
      def show
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :schedule?

        term_id = params[:term_id]
        
        @enrollments = @student.enrollments
                              .includes(section: [:course, :professor])
                              .order('courses.code')

        if term_id
          @enrollments = @enrollments.where(academic_term_id: term_id)
        else
          # Default to current active term
          active_term = AcademicTerm.find_by(is_active: true)
          @enrollments = @enrollments.where(academic_term_id: active_term.id) if active_term
        end

        schedule_data = @enrollments.map do |enrollment|
          section = enrollment.section
          {
            section_id: section.id,
            course_code: section.course.code,
            course_name: section.course.name,
            professor: section.professor.user.full_name,
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

      def ics
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :schedule?

        term_id = params[:term_id]
        
        @enrollments = @student.enrollments
                              .includes(section: [:course, :professor, :academic_term])

        if term_id
          @enrollments = @enrollments.where(academic_term_id: term_id)
        else
          active_term = AcademicTerm.find_by(is_active: true)
          @enrollments = @enrollments.where(academic_term_id: active_term.id) if active_term
        end

        ics_content = ScheduleExporter.new(@enrollments).generate_ics

        send_data ics_content,
                  filename: "schedule_#{@student.student_number}.ics",
                  type: 'text/calendar',
                  disposition: 'attachment'
      end
    end
  end
end
