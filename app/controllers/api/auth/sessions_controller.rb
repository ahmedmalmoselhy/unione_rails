module Api
  module Auth
    class SessionsController < ApplicationController
      skip_before_action :authenticate_user_from_token, raise: false
      before_action :authenticate_user_from_token, only: [:show, :destroy]

      # POST /api/auth/login
      def create
        user = User.find_by(email: params[:email].to_s.downcase)

        if user&.authenticate(params[:password])
          return render_error('Your account is inactive. Please contact support.', :forbidden) unless user.is_active

          token = JwtService.generate_token(user)
          token_string = user.create_token(
            name: 'Web Login',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          )

          user.update!(last_login_at: Time.current)

          render json: {
            success: true,
            message: 'Login successful',
            data: {
              user: user_json(user),
              token: token
            }
          }, status: :ok
        else
          render json: {
            success: false,
            error: 'Invalid email or password'
          }, status: :unauthorized
        end
      end

      # GET /api/auth/me
      def show
        return render_unauthorized unless current_user

        render json: {
          success: true,
          data: {
            user: user_json(current_user)
          }
        }, status: :ok
      end

      # DELETE /api/auth/logout
      def destroy
        return render_unauthorized unless current_user

        # Revoke all tokens for this user
        current_user.personal_access_tokens.active.update_all(revoked_at: Time.current)

        render json: {
          success: true,
          message: 'Logged out successfully'
        }, status: :ok
      end

      private

      def authenticate_user_from_token
        authenticate_with_http_token do |token, _options|
          payload = JwtService.decode(token)
          return nil unless payload

          @current_user = User.active.find_by(id: payload[:user_id])
        end
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          phone: user.phone,
          avatar_url: user.avatar_url,
          roles: user.role_slugs,
          last_login_at: user.last_login_at,
          created_at: user.created_at
        }
      end
    end
  end
end
