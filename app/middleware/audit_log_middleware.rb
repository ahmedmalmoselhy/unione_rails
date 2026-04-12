class AuditLogMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Extract user from JWT token
    auth_header = env['HTTP_AUTHORIZATION']
    if auth_header
      token = auth_header.gsub('Bearer ', '')
      payload = JwtService.decode(token)
      if payload
        Current.user = User.find_by(id: payload[:user_id])
      end
    end
    
    Current.ip_address = request.remote_ip

    @app.call(env)
  ensure
    Current.reset
  end
end
