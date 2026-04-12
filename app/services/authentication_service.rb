class AuthenticationService
  attr_reader :errors

  def initialize
    @errors = []
  end

  # Authenticate user with email and password
  def authenticate(email, password, options = {})
    user = ::User.find_by(email: email&.downcase)

    unless user&.authenticate(password)
      @errors << 'Invalid email or password'
      return nil
    end

    unless user.is_active
      @errors << 'Your account is inactive. Please contact support.'
      return nil
    end

    # Update last login time
    user.update(last_login_at: DateTime.current)

    # Generate JWT token
    token = JwtService.generate_token(user)

    # Create personal access token
    token_string = user.create_token(
      name: options[:token_name] || 'API Login',
      ip_address: options[:ip_address],
      user_agent: options[:user_agent]
    )

    {
      user: user,
      token: token,
      token_string: token_string
    }
  end

  # Register a new user
  def register(user_params, role_slug = 'student')
    user = ::User.new(user_params)

    unless user.save
      @errors = user.errors.full_messages
      return nil
    end

    # Assign role
    role = ::Role.find_by(slug: role_slug)
    if role
      user.roles << role
    else
      @errors << "Role '#{role_slug}' not found"
      user.destroy
      return nil
    end

    # Generate token
    token = JwtService.generate_token(user)

    {
      user: user,
      token: token
    }
  end

  # Verify token
  def verify_token(token)
    payload = JwtService.decode(token)
    return nil unless payload

    user = ::User.active.find_by(id: payload[:user_id])
    return nil unless user

    user
  end

  # Change password
  def change_password(user, current_password, new_password, password_confirmation)
    unless user.authenticate(current_password)
      @errors << 'Current password is incorrect'
      return false
    end

    if new_password != password_confirmation
      @errors << 'New password and confirmation do not match'
      return false
    end

    if new_password.length < 6
      @errors << 'Password must be at least 6 characters'
      return false
    end

    user.update(
      password: new_password,
      must_change_password: false
    )
  end

  # Generate password reset token
  def generate_password_reset_token(email)
    user = ::User.find_by(email: email&.downcase)
    
    unless user
      # Don't reveal if email exists
      return true
    end

    token = SecureRandom.urlsafe_base64(32)
    
    ::PasswordResetToken.create!(
      email: user.email,
      token: token,
      created_at: DateTime.current
    )

    # Send password reset email
    PasswordMailer.password_reset(user, token).deliver_later

    true
  end

  # Reset password with token
  def reset_password(token, new_password, password_confirmation)
    reset_token = ::PasswordResetToken.find_by(token: token)

    unless reset_token
      @errors << 'Invalid reset token'
      return false
    end

    # Check if token is expired (1 hour)
    if reset_token.created_at < 1.hour.ago
      @errors << 'Reset token has expired'
      return false
    end

    if new_password != password_confirmation
      @errors << 'Password and confirmation do not match'
      return false
    end

    user = ::User.find_by(email: reset_token.email)
    
    unless user
      @errors << 'User not found'
      return false
    end

    user.update(
      password: new_password,
      must_change_password: false
    )

    # Delete used token
    reset_token.destroy

    true
  end

  # Logout user
  def logout(user)
    # Revoke all tokens
    user.personal_access_tokens.active.update_all(revoked_at: DateTime.current)
  end
end
