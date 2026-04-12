module Api
  module Auth
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_user_from_token, only: [:create], raise: false

      # POST /api/auth/register
      def create
        user = User.new(registration_params)

        if user.save
          assign_default_role(user)
          token_string = user.create_token
          token = JwtService.generate_token(user)

          render json: {
            success: true,
            message: 'Registration successful',
            data: {
              user: user_json(user),
              token: token
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def registration_params
        params.require(:user).permit(
          :email, :password, :password_confirmation,
          :first_name, :last_name, :phone
        )
      end

      def assign_default_role(user)
        role = Role.find_by(slug: 'student') || Role.first
        user.roles << role if role
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          roles: user.role_slugs,
          created_at: user.created_at
        }
      end
    end
  end
end
