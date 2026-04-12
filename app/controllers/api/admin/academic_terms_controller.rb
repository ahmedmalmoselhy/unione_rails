module Api
  module Admin
    class AcademicTermsController < BaseController
      before_action :set_academic_term, only: [:show, :update, :destroy]

      def index
        @academic_terms = AcademicTerm.order(start_date: :desc)
        authorize AcademicTerm

        render json: @academic_terms, status: :ok
      end

      def show
        authorize @academic_term

        render json: @academic_term, status: :ok
      end

      def create
        @academic_term = AcademicTerm.new(academic_term_params)
        authorize @academic_term

        if @academic_term.save
          render json: @academic_term, status: :created
        else
          render json: { errors: @academic_term.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @academic_term

        if @academic_term.update(academic_term_params)
          render json: @academic_term, status: :ok
        else
          render json: { errors: @academic_term.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @academic_term

        @academic_term.destroy
        render json: { message: 'Academic term deleted' }, status: :ok
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
    end
  end
end
