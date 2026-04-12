module Api
  module Admin
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update, :destroy, :assign_role, :remove_role, :activate, :deactivate]

      def index
        authorize User

        @users = User.includes(:roles)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page] || 20)

        # Filters
        if params[:role]
          @users = @users.joins(:roles).where(roles: { slug: params[:role] })
        end

        if params[:active] == 'true'
          @users = @users.where(is_active: true)
        elsif params[:active] == 'false'
          @users = @users.where(is_active: false)
        end

        if params[:search]
          search_term = "%#{params[:search]}%"
          @users = @users.where('first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?', search_term, search_term, search_term)
        end

        render json: {
          success: true,
          data: {
            users: @users.map { |user| user_json(user) },
            total: @users.total_count,
            page: @users.current_page
          }
        }, status: :ok
      end

      def show
        authorize @user

        render json: {
          success: true,
          data: {
            user: user_json(@user, include_details: true)
          }
        }, status: :ok
      end

      def create
        @user = User.new(user_params)
        authorize @user

        if @user.save
          render json: {
            success: true,
            message: 'User created successfully',
            data: {
              user: user_json(@user)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @user

        if @user.update(user_params)
          render json: {
            success: true,
            data: {
              user: user_json(@user)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @user

        @user.update(deleted_at: DateTime.current, is_active: false)
        
        render json: {
          success: true,
          message: 'User deactivated'
        }, status: :ok
      end

      def assign_role
        authorize @user

        role = Role.find_by(slug: params[:role_slug])
        
        unless role
          return render json: {
            success: false,
            error: 'Role not found'
          }, status: :not_found
        end

        unless @user.roles.include?(role)
          @user.roles << role
        end

        render json: {
          success: true,
          message: "Role '#{role.name}' assigned to user",
          data: {
            user: user_json(@user)
          }
        }, status: :ok
      end

      def remove_role
        authorize @user

        role = @user.roles.find_by(slug: params[:role_slug])
        
        unless role
          return render json: {
            success: false,
            error: 'User does not have this role'
          }, status: :unprocessable_entity
        end

        @user.roles.destroy(role)

        render json: {
          success: true,
          message: "Role '#{role.name}' removed from user",
          data: {
            user: user_json(@user)
          }
        }, status: :ok
      end

      def activate
        authorize @user

        @user.update(is_active: true, deleted_at: nil)

        render json: {
          success: true,
          message: 'User activated',
          data: {
            user: user_json(@user)
          }
        }, status: :ok
      end

      def deactivate
        authorize @user

        @user.update(is_active: false)

        render json: {
          success: true,
          message: 'User deactivated',
          data: {
            user: user_json(@user)
          }
        }, status: :ok
      end

      def statistics
        authorize User

        stats = {
          total_users: User.count,
          active_users: User.where(is_active: true).count,
          inactive_users: User.where(is_active: false).count,
          users_by_role: Role.joins(:users)
                            .group('roles.slug', 'roles.name')
                            .count('users.id')
                            .map { |k, v| { role: k[1], slug: k[0], count: v } },
          recent_registrations: User.where('created_at >= ?', 7.days.ago).count,
          students_count: User.joins(:roles).where(roles: { slug: 'student' }).count,
          professors_count: User.joins(:roles).where(roles: { slug: 'professor' }).count,
          employees_count: User.joins(:roles).where(roles: { slug: 'employee' }).count
        }

        render json: {
          success: true,
          data: stats
        }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_json(user, include_details: false)
        json = {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          phone: user.phone,
          is_active: user.is_active,
          roles: user.roles.pluck(:slug),
          created_at: user.created_at,
          updated_at: user.updated_at
        }

        if include_details
          json.merge!({
            national_id: user.national_id,
            gender: user.gender,
            date_of_birth: user.date_of_birth,
            email_verified_at: user.email_verified_at,
            last_login_at: user.last_login_at,
            student: user.student&.as_json(only: [:student_number, :academic_year, :gpa]),
            professor: user.professor&.as_json(only: [:staff_number, :academic_rank, :specialization]),
            employee: user.employee&.as_json(only: [:staff_number, :position])
          })
        end

        json
      end

      def user_params
        params.require(:user).permit(
          :email, :password, :password_confirmation, :first_name, :last_name,
          :phone, :gender, :date_of_birth, :is_active
        )
      end
    end
  end
end
