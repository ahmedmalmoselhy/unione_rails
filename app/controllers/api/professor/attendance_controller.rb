module Api
  module Professor
    class AttendanceController < BaseController
      before_action :set_professor
      before_action :set_section

      def index
        authorize @section, :attendance?

        @sessions = @section.attendance_sessions
                           .includes(:attendance_records)
                           .order(date: :desc)

        render json: {
          success: true,
          data: {
            section: {
              id: @section.id,
              course_code: @section.course.code,
              course_name: @section.course.name
            },
            sessions: @sessions.map { |session| session_json(session) }
          }
        }, status: :ok
      end

      def show
        @session = @section.attendance_sessions.find(params[:session_id])
        authorize @session, :show?

        @records = @session.attendance_records
                          .includes(student: :user)
                          .order('users.last_name, users.first_name')

        render json: {
          success: true,
          data: {
            session: session_json(@session),
            records: @records.map { |record| record_json(record) }
          }
        }, status: :ok
      end

      def create
        authorize @section, :create_attendance?

        session = AttendanceService.new.create_session(
          @section,
          date: params[:date] || Date.current,
          session_number: params[:session_number] || next_session_number
        )

        render json: {
          success: true,
          message: 'Attendance session created',
          data: {
            session: session_json(session)
          }
        }, status: :created
      end

      def update
        @session = @section.attendance_sessions.find(params[:session_id])
        authorize @session, :update?

        # Bulk attendance recording
        attendance_data = params[:attendance] || []
        results = AttendanceService.new.bulk_record_attendance(@session, attendance_data)

        render json: {
          success: true,
          message: "Attendance recorded: #{results[:success]} succeeded, #{results[:failed]} failed",
          data: results
        }, status: :ok
      end

      def close
        @session = @section.attendance_sessions.find(params[:session_id])
        authorize @session, :update?

        AttendanceService.new.close_session(@session)

        render json: {
          success: true,
          message: 'Attendance session closed'
        }, status: :ok
      end

      def statistics
        authorize @section, :attendance?

        stats = AttendanceService.new.attendance_statistics(@section)

        render json: {
          success: true,
          data: stats
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

      def set_section
        @section = @professor.sections.find(params[:section_id])
      end

      def next_session_number
        (@section.attendance_sessions.maximum(:session_number) || 0) + 1
      end

      def session_json(session)
        {
          id: session.id,
          date: session.date,
          session_number: session.session_number,
          status: session.status,
          records_count: session.attendance_records.count,
          created_at: session.created_at
        }
      end

      def record_json(record)
        {
          id: record.id,
          student: {
            id: record.student.id,
            student_number: record.student.student_number,
            name: record.student.user.full_name
          },
          status: record.status,
          note: record.note,
          created_at: record.created_at
        }
      end
    end
  end
end
