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

      def ics
        @sections = @professor.sections.includes(:course, :academic_term)

        if params[:term_id]
          @sections = @sections.where(academic_term_id: params[:term_id])
        else
          active_term = AcademicTerm.find_by(is_active: true)
          @sections = @sections.where(academic_term_id: active_term.id) if active_term
        end

        cal = Icalendar::Calendar.new
        cal.timezone do |t|
          t.tzid = 'Asia/Riyadh'
          t.standard do |s|
            s.tzoffsetfrom = '+0300'
            s.tzoffsetto = '+0300'
            s.tzname = 'AST'
          end
        end

        @sections.each do |section|
          next if section.schedule.blank?

          days = section.schedule['days'] || []
          start_time = section.schedule['start_time']
          end_time = section.schedule['end_time']
          location = section.schedule['location']
          term = section.academic_term

          days.each do |day_num|
            first_date = find_first_occurrence(term.start_date, day_num.to_i)
            weeks_count = ((term.end_date - term.start_date).to_i / 7).to_i

            Icalendar::Event.new(cal) do |e|
              e.summary = "#{section.course.code} - #{section.course.name}"
              e.description = "Section: #{section.id}\nProfessor: #{current_user.full_name}"
              e.location = location
              e.dtstart = Icalendar::Values::DateTime.new(
                Time.zone.local(first_date.year, first_date.month, first_date.day) + time_to_seconds(start_time),
                'Asia/Riyadh'
              )
              e.dtend = Icalendar::Values::DateTime.new(
                Time.zone.local(first_date.year, first_date.month, first_date.day) + time_to_seconds(end_time),
                'Asia/Riyadh'
              )
              e.rrule = "FREQ=WEEKLY;COUNT=#{weeks_count}"
            end
          end
        end

        cal.publish

        send_data cal.to_ical,
                  type: 'text/calendar',
                  disposition: 'attachment',
                  filename: "professor-schedule-#{current_user.id}.ics"
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

      def find_first_occurrence(start_date, target_wday)
        date = start_date.to_date
        while date.wday != target_wday
          date += 1.day
        end
        date
      end

      def time_to_seconds(time_str)
        hours, minutes = time_str.split(':').map(&:to_i)
        hours.hours + minutes.minutes
      end
    end
  end
end
