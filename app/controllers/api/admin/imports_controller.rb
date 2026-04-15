module Api
  module Admin
    class ImportsController < BaseController
      def students
        authorize ::Student

        unless params[:file].present?
          return render json: { success: false, error: 'No file provided' }, status: :unprocessable_entity
        end

        unless params[:faculty_id].present? && params[:department_id].present?
          return render json: {
            success: false,
            error: 'faculty_id and department_id are required'
          }, status: :unprocessable_entity
        end

        file_data = read_excel_data(params[:file])
        result = StudentImportService.new.import_from_array(file_data, params[:faculty_id], params[:department_id])

        render_import_result(result, 'Student import completed')
      rescue StandardError => e
        render json: { success: false, error: "Import failed: #{e.message}" }, status: :unprocessable_entity
      end

      def grades
        authorize ::Section

        unless params[:file].present?
          return render json: { success: false, error: 'No file provided' }, status: :unprocessable_entity
        end

        section = ::Section.find(params[:section_id])
        academic_term_id = params[:academic_term_id] || section.academic_term_id

        file_data = read_excel_data(params[:file])
        result = GradeImportService.new.import_from_array(file_data, section.id, academic_term_id)

        render_import_result(result, 'Grade import completed')
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: 'Section not found' }, status: :not_found
      rescue StandardError => e
        render json: { success: false, error: "Import failed: #{e.message}" }, status: :unprocessable_entity
      end

      def professors
        authorize ::Professor

        render json: {
          success: false,
          error: 'Professor import is not implemented yet'
        }, status: :not_implemented
      end

      def students_template
        authorize ::Student
        send_data students_template_stream,
                  filename: 'student_import_template.xlsx',
                  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      def grades_template
        authorize ::Section
        send_data grades_template_stream,
                  filename: 'grade_import_template.xlsx',
                  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      private

      def read_excel_data(file)
        filepath = file.respond_to?(:tempfile) ? file.tempfile.path : file.path
        spreadsheet = Roo::Excelx.new(filepath)
        headers = spreadsheet.row(1)

        (2..spreadsheet.last_row).map do |index|
          Hash[headers.zip(spreadsheet.row(index))]
        end
      end

      def render_import_result(result, prefix)
        render json: {
          success: result[:success],
          message: "#{prefix}: #{result[:imported]} imported, #{result[:failed]} failed",
          data: {
            imported: result[:imported],
            failed: result[:failed],
            errors: result[:errors]
          }
        }, status: result[:success] ? :ok : :multi_status
      end

      def students_template_stream
        package = Axlsx::Package.new
        package.workbook.add_worksheet(name: 'Students') do |sheet|
          sheet.add_row %w[student_number first_name last_name email academic_year]
          sheet.add_row ['STD001', 'John', 'Doe', 'john@example.com', 1]
        end
        package.to_stream.read
      end

      def grades_template_stream
        package = Axlsx::Package.new
        package.workbook.add_worksheet(name: 'Grades') do |sheet|
          sheet.add_row %w[student_number course_code points letter_grade]
          sheet.add_row ['STD001', 'CS101', 85, 'A']
        end
        package.to_stream.read
      end
    end
  end
end
