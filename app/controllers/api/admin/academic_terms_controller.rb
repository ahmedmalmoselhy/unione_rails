module Api
  module Admin
    class AcademicTermsController < BaseController
      before_action :set_academic_term, only: [:show, :update, :destroy, :activate, :deactivate]

      def index
        @academic_terms = AcademicTerm.order(start_date: :desc)
        authorize AcademicTerm

        render json: {
          success: true,
          data: {
            academic_terms: @academic_terms.map { |term| term_json(term) }
          }
        }, status: :ok
      end

      def show
        authorize @academic_term

        render json: {
          success: true,
          data: {
            academic_term: term_json(@academic_term)
          }
        }, status: :ok
      end

      def create
        @academic_term = AcademicTerm.new(academic_term_params)
        authorize @academic_term

        if @academic_term.save
          render json: {
            success: true,
            message: 'Academic term created',
            data: {
              academic_term: term_json(@academic_term)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @academic_term.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @academic_term

        if @academic_term.update(academic_term_params)
          render json: {
            success: true,
            data: {
              academic_term: term_json(@academic_term)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @academic_term.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @academic_term

        # Check if term has enrollments
        if @academic_term.enrollments.any?
          return render json: {
            success: false,
            error: 'Cannot delete term with existing enrollments'
          }, status: :unprocessable_entity
        end

        @academic_term.destroy
        render json: {
          success: true,
          message: 'Academic term deleted'
        }, status: :ok
      end

      def activate
        authorize @academic_term

        # Deactivate all other terms
        AcademicTerm.where.not(id: @academic_term.id).update_all(is_active: false)
        @academic_term.update(is_active: true)

        render json: {
          success: true,
          message: "Academic term '#{@academic_term.name}' is now active",
          data: {
            academic_term: term_json(@academic_term)
          }
        }, status: :ok
      end

      def deactivate
        authorize @academic_term

        @academic_term.update(is_active: false)

        render json: {
          success: true,
          message: "Academic term '#{@academic_term.name}' deactivated",
          data: {
            academic_term: term_json(@academic_term)
          }
        }, status: :ok
      end

      def current
        @current_term = AcademicTerm.find_by(is_active: true)

        if @current_term
          render json: {
            success: true,
            data: {
              academic_term: term_json(@current_term)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            error: 'No active academic term'
          }, status: :not_found
        end
      end

      private

      def set_academic_term
        @academic_term = AcademicTerm.find(params[:id])
      end

      def academic_term_params
        params.require(:academic_term).permit(
          :name, :start_date, :end_date, :registration_start,
          :registration_end, :is_active
        )
      end

      def term_json(term)
        {
          id: term.id,
          name: term.name,
          start_date: term.start_date,
          end_date: term.end_date,
          registration_start: term.registration_start,
          registration_end: term.registration_end,
          is_active: term.is_active,
          sections_count: term.sections.count,
          enrollments_count: term.enrollments.count,
          created_at: term.created_at,
          updated_at: term.updated_at
        }
      end
    end
  end
end
