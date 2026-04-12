module Api
  module Student
    class AttendanceController < BaseController
      def index
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :attendance?

        section_id = params[:section_id]
        
        @records = AttendanceRecord.joins(:attendance_session)
                                   .where(student_id: @student.id)
                                   .includes(attendance_session: :section)
                                   .order('attendance_sessions.date DESC')

        if section_id
          @records = @records.where(attendance_sessions: { section_id: section_id })
        end

        attendance_summary = calculate_summary(@records)

        render json: {
          success: true,
          data: {
            attendance_records: @records.map { |record| record_json(record) },
            summary: attendance_summary
          }
        }, status: :ok
      end

      def by_section
        @student = current_user.student
        section = Section.find(params[:section_id])

        authorize @student, :attendance?

        # Verify student is enrolled in this section
        unless @student.enrollments.exists?(section_id: section.id)
          return render json: {
            success: false,
            error: 'Student not enrolled in this section'
          }, status: :forbidden
        end

        @records = AttendanceRecord.joins(:attendance_session)
                                   .where(student_id: @student.id,
                                         attendance_sessions: { section_id: section.id })
                                   .includes(attendance_session: :section)
                                   .order('attendance_sessions.date DESC')

        attendance_summary = calculate_summary(@records)

        render json: {
          success: true,
          data: {
            section: {
              id: section.id,
              course_code: section.course.code,
              course_name: section.course.name
            },
            attendance_records: @records.map { |record| record_json(record) },
            summary: attendance_summary
          }
        }, status: :ok
      end

      private

      def calculate_summary(records)
        total = records.count
        present = records.where(status: :present).count
        absent = records.where(status: :absent).count
        late = records.where(status: :late).count

        {
          total_sessions: total,
          present: present,
          absent: absent,
          late: late,
          attendance_rate: total.positive? ? ((present + late) / total.to_f * 100).round(2) : 0
        }
      end

      def record_json(record)
        {
          id: record.id,
          session: {
            id: record.attendance_session.id,
            date: record.attendance_session.date,
            session_number: record.attendance_session.session_number
          },
          section: {
            id: record.attendance_session.section.id,
            course_code: record.attendance_session.section.course.code,
            course_name: record.attendance_session.section.course.name
          },
          status: record.status,
          note: record.note,
          created_at: record.created_at
        }
      end
    end
  end
end
