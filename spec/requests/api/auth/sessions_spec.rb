require 'rails_helper'

RSpec.describe 'Api::Auth::Sessions', type: :request do
  let!(:user) { create(:user, :student, password: 'password123') }

  describe 'POST /api/auth/login' do
    it 'returns token for valid credentials' do
      post '/api/auth/login', params: {
        email: user.email,
        password: 'password123'
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data']['token']).to be_present
      expect(json['data']['user']['email']).to eq(user.email)
    end

    it 'returns error for invalid password' do
      post '/api/auth/login', params: {
        email: user.email,
        password: 'wrongpassword'
      }, as: :json

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid email or password')
    end

    it 'returns error for non-existent email' do
      post '/api/auth/login', params: {
        email: 'nonexistent@example.com',
        password: 'password123'
      }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error for inactive user' do
      inactive_user = create(:user, :inactive, :student, password: 'password123')

      post '/api/auth/login', params: {
        email: inactive_user.email,
        password: 'password123'
      }, as: :json

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json['error']).to include('inactive')
    end
  end

  describe 'GET /api/auth/me' do
    let(:headers) do
      post '/api/auth/login', params: { email: user.email, password: 'password123' }, as: :json
      { 'Authorization' => "Bearer #{JSON.parse(response.body)['data']['token']}" }
    end

    it 'returns current user info' do
      get '/api/auth/me', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['user']['email']).to eq(user.email)
      expect(json['data']['user']['roles']).to include('student')
    end

    it 'returns unauthorized without token' do
      get '/api/auth/me'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/auth/logout' do
    let(:headers) do
      post '/api/auth/login', params: { email: user.email, password: 'password123' }, as: :json
      { 'Authorization' => "Bearer #{JSON.parse(response.body)['data']['token']}" }
    end

    it 'logs out successfully' do
      delete '/api/auth/logout', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end

    it 'returns unauthorized without token' do
      delete '/api/auth/logout'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
