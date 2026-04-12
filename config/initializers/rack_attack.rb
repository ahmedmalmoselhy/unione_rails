# Be sure to restart your server when you modify this file.

# Skip rate limiting in test environment
unless Rails.env.test?
  # Throttle login attempts by IP
  Rack::Attack.throttle('logins/ip', limit: 20, period: 1.minute) do |req|
    if req.path == '/api/auth/login' && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email
  Rack::Attack.throttle('logins/email', limit: 10, period: 5.minutes) do |req|
    if req.path == '/api/auth/login' && req.post?
      req.params.dig('email').to_s.downcase
    end
  end

  # Throttle registration
  Rack::Attack.throttle('registrations/ip', limit: 10, period: 5.minutes) do |req|
    if req.path == '/api/auth/register' && req.post?
      req.ip
    end
  end

  # Throttle password reset
  Rack::Attack.throttle('password_resets/email', limit: 5, period: 1.hour) do |req|
    if req.path == '/api/auth/forgot-password' && req.post?
      req.params.dig('email').to_s.downcase
    end
  end

  # Custom response for throttled requests
  Rack::Attack.throttled_responder = lambda do |_request|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Too many requests. Please try again later.' }.to_json]]
  end
end
