require 'json'
require 'bcrypt'

module JwtService
  SECRET_KEY = ENV.fetch('JWT_SECRET', Rails.application.credentials.secret_key_base || 'fallback_secret')
  ALGORITHM = 'HS256'
  EXPIRATION = 7.days

  def self.encode(payload)
    payload = payload.dup
    payload[:exp] = EXPIRATION.from_now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError
    nil
  end

  def self.generate_token(user)
    encode(
      user_id: user.id,
      email: user.email,
      roles: user.roles.pluck(:slug)
    )
  end
end
