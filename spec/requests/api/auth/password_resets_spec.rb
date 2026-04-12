require 'rails_helper'

RSpec.describe 'Api::Auth::PasswordResets', type: :request do
  let!(:user) { create(:user, :student, password: 'oldpassword123') }

  describe 'POST /api/auth/forgot-password' do
    it 'creates a password reset token and returns success' do
      expect {
        post '/api/auth/forgot-password', params: { email: user.email }, as: :json
      }.to change(PasswordResetToken, :count).by(1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end

    it 'returns success even for non-existent email (prevent enumeration)' do
      expect {
        post '/api/auth/forgot-password', params: { email: 'nonexistent@example.com' }, as: :json
      }.not_to change(PasswordResetToken, :count)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end
  end

  describe 'POST /api/auth/reset-password' do
    let!(:reset_token) { user.generate_password_reset_token }

    it 'resets password with valid token' do
      post '/api/auth/reset-password', params: {
        token: reset_token.token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true

      # Verify new password works
      user.reload
      expect(user.authenticate('newpassword123')).to eq(user)
    end

    it 'returns error for invalid token' do
      post '/api/auth/reset-password', params: {
        token: 'invalid_token',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid or expired reset token')
    end

    it 'returns error for expired token' do
      reset_token.update!(expires_at: 2.hours.ago)

      post '/api/auth/reset-password', params: {
        token: reset_token.token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'marks token as used after successful reset' do
      post '/api/auth/reset-password', params: {
        token: reset_token.token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(reset_token.reload.used?).to be true
    end
  end
end
