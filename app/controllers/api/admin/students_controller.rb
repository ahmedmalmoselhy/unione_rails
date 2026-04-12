module Api
  module Admin
    class StudentsController < BaseController
      before_action :set_student, only: [:show, :update, :destroy, :activate, :deactivate, :graduate]

      def index
        authorize ::Student

        @students = ::Student.includes(:user, :faculty, :department)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(params[:per_page] || 20)

        # Filters
        if params[:status]
          @students = @students.where(enrollment_status: params[:status])
        end

        if params[:faculty_id]
          @students = @students.where(faculty_id: params[:faculty_id])
        end

        if params[:department_id]
          @students = @students.where(department_id: params[:department_id])
        end

        if params[:search]
          search_term = "%#{params[:search]}%"
          @students = @students.joins(:user)
                               .where('users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR students.student_number ILIKE ?',
                                      search_term, search_term, search_term, search_term)
        end

        render json: {
          success: true,
          data: {
            students: @students.map { |s| student_json(s) },
            total: @students.total_count,
            page: @students.current_page
          }
        }, status: :ok
      end

      def show
        authorize @student

        render json: {
          success: true,
          data: {
            student: student_json(@student, include_details: true)
          }
        }, status: :ok
      end

      def create
        @student = ::Student.new(student_params)
        authorize @student

        if @student.save
          render json: {
            success: true,
            message: 'Student created successfully',
            data: {
              student: student_json(@student)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @student.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @student

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

      def destroy
        authorize @student

        @student.update(enrollment_status: :suspended)
        
        render json: {
          success: true,
          message: 'Student suspended'
        }, status: :ok
      end

      def activate
        authorize @student

        @student.update(enrollment_status: :active)

        render json: {
          success: true,
          message: 'Student activated',
          data: {
            student: student_json(@student)
          }
        }, status: :ok
      end

      def deactivate
        authorize @student

        @student.update(enrollment_status: :suspended)

        render json: {
          success: true,
          message: 'Student suspended',
          data: {
            student: student_json(@student)
          }
        }, status: :ok
      end

      def graduate
        authorize @student

        @student.update(
          enrollment_status: :graduated,
          graduated_at: Date.current
        )

        render json: {
          success: true,
          message: 'Student graduated',
          data: {
            student: student_json(@student)
          }
        }, status: :ok
      end

      def statistics
        authorize ::Student

        stats = {
          total_students: ::Student.count,
          active_students: ::Student.where(enrollment_status: :active).count,
          graduated_students: ::Student.where(enrollment_status: :graduated).count,
          suspended_students: ::Student.where(enrollment_status: :suspended).count,
          average_gpa: ::Student.where.not(gpa: nil).average('gpa')&.to_f&.round(2),
          students_by_faculty: ::Faculty.joins(:students)
                                       .group('faculties.name')
                                       .count('students.id'),
          students_by_year: ::Student.group(:academic_year).count,
          students_by_standing: ::Student.group(:academic_standing).count
        }

        render json: {
          success: true,
          data: stats
        }, status: :ok
      end

      private

      def set_student
        @student = ::Student.find(params[:id])
      end

      def student_json(student, include_details: false)
        json = {
          id: student.id,
          student_number: student.student_number,
          user: {
            id: student.user.id,
            first_name: student.user.first_name,
            last_name: student.user.last_name,
            email: student.user.email
          },
          faculty: {
            id: student.faculty.id,
            name: student.faculty.name
          },
          department: {
            id: student.department.id,
            name: student.department.name
          },
          academic_year: student.academic_year,
          semester: student.semester,
          enrollment_status: student.enrollment_status,
          gpa: student.gpa,
          academic_standing: student.academic_standing,
          enrolled_at: student.enrolled_at,
          created_at: student.created_at
        }

        if include_details
          json.merge!({
            user: student.user.as_json(only: [:id, :first_name, :last_name, :email, :phone, :gender, :date_of_birth]),
            graduated_at: student.graduated_at,
            updated_at: student.updated_at
          })
        end

        json
      end

      def student_params
        params.require(:student).permit(
          :user_id, :faculty_id, :department_id, :academic_year, :semester,
          :enrollment_status, :gpa, :academic_standing, :enrolled_at, :graduated_at
        )
      end
    end
  end
end
