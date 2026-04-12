module Api
  module Auth
    class TokensController < ApplicationController
      before_action :authenticate_user!

      # GET /api/auth/tokens
      def index
        tokens = current_user.personal_access_tokens
                             .select('id, name, created_at, last_used_at, expires_at, revoked_at')
                             .order(created_at: :desc)

        render json: {
          success: true,
          data: {
            tokens: tokens.as_json(only: [:id, :name, :created_at, :last_used_at, :expires_at])
          }
        }, status: :ok
      end

      # DELETE /api/auth/tokens (revoke all)
      def destroy
        if params[:id]
          # Revoke specific token
          token = current_user.personal_access_tokens.find_by(id: params[:id])
          return render_error('Token not found', :not_found) unless token

          token.revoke!
          render json: { success: true, message: 'Token revoked' }, status: :ok
        else
          # Revoke all tokens
          current_user.personal_access_tokens.active.update_all(revoked_at: Time.current)
          render json: { success: true, message: 'All tokens revoked' }, status: :ok
        end
      end
    end
  end
end
