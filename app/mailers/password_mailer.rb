class PasswordMailer < ApplicationMailer
  default from: 'passwords@unione.com'

  def password_reset(user, token)
    @user = user
    @token = token
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/reset-password?token=#{token}"
    
    mail(
      to: @user.email,
      subject: 'Reset Your Password - UniOne'
    )
  end
end
