class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  private

  def current_user
    @current_user ||= authenticate_user_from_token
  end

  def authenticate_user_from_token
    authenticate_with_http_token do |token, _options|
      payload = JwtService.decode(token)
      return nil unless payload

      user = User.find_by(id: payload[:user_id])
      return nil unless user

      # Verify token hasn't been revoked
      return nil if user.personal_access_tokens.where.not(revoked_at: nil).exists?

      user
    end
  end

  def authenticate_user!
    return if current_user

    render json: { error: 'Unauthorized. Please log in.' }, status: :unauthorized
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end

  def render_not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_forbidden
    render json: { error: 'Forbidden. You do not have permission to access this resource.' }, status: :forbidden
  end

  def render_error(message, status = :bad_request)
    render json: { error: message }, status: status
  end

  def render_success(data = nil, message = nil, status = :ok)
    response = { success: true }
    response[:message] = message if message
    response[:data] = data if data
    render json: response, status: status
  end
end
