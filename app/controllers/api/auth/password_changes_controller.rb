module Api
  module Auth
    class PasswordChangesController < ApplicationController
      before_action :authenticate_user!

      # POST /api/auth/change-password
      def create
        unless current_user.authenticate(params[:current_password])
          return render_error('Current password is incorrect', :unprocessable_entity)
        end

        if current_user.update(password_params)
          # Revoke all other tokens for security
          current_user.personal_access_tokens.active.update_all(revoked_at: Time.current)

          render json: {
            success: true,
            message: 'Password changed successfully. Please login again.'
          }, status: :ok
        else
          render json: {
            success: false,
            errors: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def password_params
        params.require(:password_change).permit(:current_password, :password, :password_confirmation)
      end
    end
  end
end
