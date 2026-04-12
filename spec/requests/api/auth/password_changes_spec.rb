require 'rails_helper'

RSpec.describe 'Api::Auth::PasswordChanges', type: :request do
  let!(:user) { create(:user, :student, password: 'oldpassword123') }
  let(:headers) do
    post '/api/auth/login', params: { email: user.email, password: 'oldpassword123' }, as: :json
    { 'Authorization' => "Bearer #{JSON.parse(response.body)['data']['token']}" }
  end

  describe 'POST /api/auth/change-password' do
    it 'changes password successfully' do
      post '/api/auth/change-password', params: {
        password_change: {
          current_password: 'oldpassword123',
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true

      # Verify old password no longer works
      user.reload
      expect(user.authenticate('oldpassword123')).to be false
      expect(user.authenticate('newpassword123')).to eq(user)
    end

    it 'returns error for incorrect current password' do
      post '/api/auth/change-password', params: {
        password_change: {
          current_password: 'wrongpassword',
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Current password is incorrect')
    end

    it 'returns unauthorized without token' do
      post '/api/auth/change-password', params: {
        password_change: {
          current_password: 'oldpassword123',
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
