module Api
  module Admin
    class UniversitiesController < BaseController
      before_action :set_university, only: [:show, :update, :destroy]

      def index
        @universities = University.all.order(:name)
        authorize University

        render json: @universities, status: :ok
      end

      def show
        authorize @university

        render json: @university, include: ['faculties', 'president'], status: :ok
      end

      def create
        @university = University.new(university_params)
        authorize @university

        if @university.save
          render json: @university, status: :created
        else
          render json: { errors: @university.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @university

        if @university.update(university_params)
          render json: @university, status: :ok
        else
          render json: { errors: @university.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @university

        @university.destroy
        render json: { message: 'University deleted' }, status: :ok
      end

      private

      def set_university
        @university = University.find(params[:id])
      end

      def university_params
        params.require(:university).permit(
          :name, :code, :country, :city, :established_year, :logo_path,
          :president_id, :phone, :email, :website, :address
        )
      end
    end
  end
end
