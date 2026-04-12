module Api
  module Admin
    class DepartmentsController < BaseController
      before_action :set_department, only: [:show, :update, :destroy]

      def index
        @departments = Department.includes(:faculty).order(:name)
        
        if params[:faculty_id]
          @departments = @departments.where(faculty_id: params[:faculty_id])
        end
        
        authorize Department

        render json: @departments, include: ['faculty'], status: :ok
      end

      def show
        authorize @department

        render json: @department, include: ['faculty', 'professors', 'students'], status: :ok
      end

      def create
        @department = Department.new(department_params)
        authorize @department

        if @department.save
          render json: @department, status: :created
        else
          render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @department

        if @department.update(department_params)
          render json: @department, status: :ok
        else
          render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @department

        @department.destroy
        render json: { message: 'Department deleted' }, status: :ok
      end

      private

      def set_department
        @department = Department.find(params[:id])
      end

      def department_params
        params.require(:department).permit(
          :faculty_id, :name, :name_ar, :code, :scope, 
          :is_mandatory, :required_credit_hours, :logo_path
        )
      end
    end
  end
end
