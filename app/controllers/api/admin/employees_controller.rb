module Api
  module Admin
    class EmployeesController < BaseController
      before_action :set_employee, only: [:show, :update, :destroy]

      def index
        authorize ::Employee

        @employees = ::Employee.includes(:user, :department)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(params[:per_page] || 20)

        if params[:department_id]
          @employees = @employees.where(department_id: params[:department_id])
        end

        if params[:position]
          @employees = @employees.where(position: params[:position])
        end

        render json: {
          success: true,
          data: {
            employees: @employees.map { |e| employee_json(e) },
            total: @employees.total_count,
            page: @employees.current_page
          }
        }, status: :ok
      end

      def show
        authorize @employee

        render json: {
          success: true,
          data: {
            employee: employee_json(@employee, include_details: true)
          }
        }, status: :ok
      end

      def create
        @employee = ::Employee.new(employee_params)
        authorize @employee

        if @employee.save
          render json: {
            success: true,
            message: 'Employee created successfully',
            data: {
              employee: employee_json(@employee)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @employee

        if @employee.update(employee_params)
          render json: {
            success: true,
            data: {
              employee: employee_json(@employee)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @employee

        @employee.destroy
        
        render json: {
          success: true,
          message: 'Employee removed'
        }, status: :ok
      end

      private

      def set_employee
        @employee = ::Employee.find(params[:id])
      end

      def employee_json(employee, include_details: false)
        json = {
          id: employee.id,
          staff_number: employee.staff_number,
          user: {
            id: employee.user.id,
            first_name: employee.user.first_name,
            last_name: employee.user.last_name,
            email: employee.user.email
          },
          department: {
            id: employee.department.id,
            name: employee.department.name
          },
          position: employee.position,
          hired_at: employee.hired_at,
          created_at: employee.created_at
        }

        if include_details
          json.merge!({
            user: employee.user.as_json(only: [:id, :first_name, :last_name, :email, :phone, :gender, :date_of_birth]),
            updated_at: employee.updated_at
          })
        end

        json
      end

      def employee_params
        params.require(:employee).permit(
          :user_id, :department_id, :staff_number, :position, :hired_at
        )
      end
    end
  end
end
