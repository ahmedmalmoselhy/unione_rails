module Api
  module Admin
    class FacultiesController < BaseController
      before_action :set_faculty, only: [:show, :update, :destroy]

      def index
        @faculties = Faculty.includes(:university).order(:name)
        
        if params[:university_id]
          @faculties = @faculties.where(university_id: params[:university_id])
        end
        
        authorize Faculty

        render json: @faculties, include: ['university'], status: :ok
      end

      def show
        authorize @faculty

        render json: @faculty, include: ['university', 'departments'], status: :ok
      end

      def create
        @faculty = Faculty.new(faculty_params)
        authorize @faculty

        if @faculty.save
          render json: @faculty, status: :created
        else
          render json: { errors: @faculty.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @faculty

        if @faculty.update(faculty_params)
          render json: @faculty, status: :ok
        else
          render json: { errors: @faculty.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @faculty

        @faculty.destroy
        render json: { message: 'Faculty deleted' }, status: :ok
      end

      private

      def set_faculty
        @faculty = Faculty.find(params[:id])
      end

      def faculty_params
        params.require(:faculty).permit(:university_id, :name, :name_ar, :code, :logo_path)
      end
    end
  end
end
