module Api
  module Admin
    class ExportsController < BaseController
      def index
        model_name = params[:model]
        format = params[:format] || 'csv'

        case model_name
        when 'students'
          export_students(format)
        when 'professors'
          export_professors(format)
        when 'courses'
          export_courses(format)
        else
          render json: { success: false, error: 'Invalid model for export' }, status: :bad_request
        end
      end

      private

      def export_students(format)
        authorize Student
        students = Student.includes(:user, :faculty, :department).all
        columns = [:student_number, :first_name, :last_name, :email, :academic_year, :gpa, :enrollment_status]
        
        # Mapping for association fields if needed, but for now simple send()
        # We might need a more sophisticated mapping in DataExporter
        
        send_export_data(students, columns, 'students', format)
      end

      def export_professors(format)
        authorize Professor
        professors = Professor.includes(:user, :department).all
        columns = [:staff_number, :first_name, :last_name, :email, :academic_rank]
        
        send_export_data(professors, columns, 'professors', format)
      end

      def export_courses(format)
        authorize Course
        courses = Course.all
        columns = [:code, :name, :description, :credit_hours, :level, :is_active]
        
        send_export_data(courses, columns, 'courses', format)
      end

      def send_export_data(collection, columns, filename, format)
        if format == 'xlsx'
          data = DataExporter.to_xlsx(collection, columns, sheet_name: filename.humanize)
          send_data data, filename: "#{filename}_#{Time.current.to_i}.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        else
          data = DataExporter.to_csv(collection, columns)
          send_data data, filename: "#{filename}_#{Time.current.to_i}.csv", type: 'text/csv'
        end
      end
    end
  end
end
