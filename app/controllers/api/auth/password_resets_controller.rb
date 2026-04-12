module Api
  module Auth
    class PasswordResetsController < ApplicationController
      skip_before_action :authenticate_user_from_token, raise: false

      # POST /api/auth/forgot-password
      def create
        user = User.find_by(email: params[:email].to_s.downcase)

        if user
          reset_token = user.generate_password_reset_token(
            request.remote_ip,
            request.user_agent
          )

          # In production, send email here
          # PasswordResetMailer.with(user: user, token: reset_token).send_reset_instructions.deliver_later

          Rails.logger.info "Password reset token for #{user.email}: #{reset_token.token}"
        end

        # Always return success to prevent email enumeration
        render json: {
          success: true,
          message: 'If an account with that email exists, we have sent password reset instructions.'
        }, status: :ok
      end

      # POST /api/auth/reset-password
      def update
        reset_token = PasswordResetToken.find_by(token: params[:token])

        unless reset_token&.valid?
          return render_error('Invalid or expired reset token', :unprocessable_entity)
        end

        user = reset_token.user

        if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          reset_token.use!
          # Revoke all tokens for security
          user.personal_access_tokens.active.update_all(revoked_at: Time.current)

          render json: {
            success: true,
            message: 'Password has been reset successfully. Please login with your new password.'
          }, status: :ok
        else
          render json: {
            success: false,
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def reset_params
        params.permit(:token, :password, :password_confirmation)
      end
    end
  end
end
