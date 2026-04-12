require 'rails_helper'

RSpec.describe 'Api::Auth::Registrations', type: :request do
  describe 'POST /api/auth/register' do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'New',
          last_name: 'User'
        }
      }
    end

    it 'creates a new user and returns token' do
      expect {
        post '/api/auth/register', params: valid_params, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data']['token']).to be_present
      expect(json['data']['user']['email']).to eq('newuser@example.com')
    end

    it 'returns error for duplicate email' do
      create(:user, email: 'existing@example.com')

      post '/api/auth/register', params: {
        user: {
          email: 'existing@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'New',
          last_name: 'User'
        }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Email has already been taken')
    end

    it 'returns error for short password' do
      post '/api/auth/register', params: {
        user: {
          email: 'newuser@example.com',
          password: 'short',
          password_confirmation: 'short',
          first_name: 'New',
          last_name: 'User'
        }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Password is too short (minimum is 6 characters)')
    end

    it 'returns error for missing fields' do
      post '/api/auth/register', params: {
        user: {
          email: 'newuser@example.com'
        }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
