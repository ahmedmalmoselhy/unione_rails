module Api
  module Admin
    class ProfessorsController < BaseController
      before_action :set_professor, only: [:show, :update, :destroy, :activate, :deactivate]

      def index
        authorize ::Professor

        @professors = ::Professor.includes(:user, :department)
                                .order(created_at: :desc)
                                .page(params[:page])
                                .per(params[:per_page] || 20)

        # Filters
        if params[:rank]
          @professors = @professors.where(academic_rank: params[:rank])
        end

        if params[:department_id]
          @professors = @professors.where(department_id: params[:department_id])
        end

        if params[:search]
          search_term = "%#{params[:search]}%"
          @professors = @professors.joins(:user)
                                   .where('users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR professors.staff_number ILIKE ?',
                                          search_term, search_term, search_term, search_term)
        end

        render json: {
          success: true,
          data: {
            professors: @professors.map { |p| professor_json(p) },
            total: @professors.total_count,
            page: @professors.current_page
          }
        }, status: :ok
      end

      def show
        authorize @professor

        render json: {
          success: true,
          data: {
            professor: professor_json(@professor, include_details: true)
          }
        }, status: :ok
      end

      def create
        @professor = ::Professor.new(professor_params)
        authorize @professor

        if @professor.save
          render json: {
            success: true,
            message: 'Professor created successfully',
            data: {
              professor: professor_json(@professor)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @professor.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @professor

        if @professor.update(professor_params)
          render json: {
            success: true,
            data: {
              professor: professor_json(@professor)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @professor.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @professor

        @professor.destroy
        
        render json: {
          success: true,
          message: 'Professor removed'
        }, status: :ok
      end

      def statistics
        authorize ::Professor

        stats = {
          total_professors: ::Professor.count,
          professors_by_rank: ::Professor.group(:academic_rank).count,
          professors_by_department: ::Department.joins(:professors)
                                                .group('departments.name')
                                                .count('professors.id'),
          average_years_of_service: calculate_average_years
        }

        render json: {
          success: true,
          data: stats
        }, status: :ok
      end

      private

      def set_professor
        @professor = ::Professor.find(params[:id])
      end

      def professor_json(professor, include_details: false)
        json = {
          id: professor.id,
          staff_number: professor.staff_number,
          user: {
            id: professor.user.id,
            first_name: professor.user.first_name,
            last_name: professor.user.last_name,
            email: professor.user.email
          },
          department: {
            id: professor.department.id,
            name: professor.department.name
          },
          specialization: professor.specialization,
          academic_rank: professor.academic_rank,
          office_location: professor.office_location,
          hired_at: professor.hired_at,
          created_at: professor.created_at
        }

        if include_details
          json.merge!({
            user: professor.user.as_json(only: [:id, :first_name, :last_name, :email, :phone, :gender, :date_of_birth]),
            sections_count: professor.sections.count,
            updated_at: professor.updated_at
          })
        end

        json
      end

      def professor_params
        params.require(:professor).permit(
          :user_id, :department_id, :staff_number, :specialization,
          :academic_rank, :office_location, :hired_at
        )
      end

      def calculate_average_years
        hired_dates = ::Professor.pluck(:hired_at).compact
        return 0.0 if hired_dates.empty?

        total_years = hired_dates.sum { |d| (Date.current - d).to_f / 365.25 }
        (total_years / hired_dates.size).round(1)
      end
    end
  end
end
