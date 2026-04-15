require 'rails_helper'

RSpec.describe 'GraphQL API', type: :request do
  let!(:user) { create(:user, :student, password: 'password123') }

  describe 'POST /graphql' do
    it 'returns current user for authenticated me query' do
      token = JwtService.generate_token(user)
      query = <<~GRAPHQL
        query {
          me {
            id
            email
            roleSlugs
          }
        }
      GRAPHQL

      post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['me']['email']).to eq(user.email)
      expect(json['data']['me']['roleSlugs']).to include('student')
    end

    it 'supports signIn mutation' do
      mutation = <<~GRAPHQL
        mutation {
          signIn(input: { email: "#{user.email}", password: "password123" }) {
            token
            user {
              id
              email
            }
            errors
          }
        }
      GRAPHQL

      post '/graphql', params: { query: mutation }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      payload = json.dig('data', 'signIn')

      expect(payload['errors']).to be_empty
      expect(payload['token']).to be_present
      expect(payload.dig('user', 'email')).to eq(user.email)
    end

    it 'rejects unauthorized notifications query' do
      query = <<~GRAPHQL
        query {
          notifications {
            id
          }
        }
      GRAPHQL

      post '/graphql', params: { query: query }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
      expect(json['errors'].first['message']).to eq('Unauthorized')
    end
  end
end
