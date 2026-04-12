require 'rails_helper'

RSpec.describe 'Student Profile API', type: :request do
  let(:student_user) { create(:student_user) }
  let(:student) { create(:student, user: student_user) }
  let(:token) { JwtService.generate_token(student_user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/student/profile' do
    it 'returns student profile successfully' do
      get '/api/student/profile', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data']['student']['student_number']).to eq(student.student_number)
    end

    it 'returns 401 when not authenticated' do
      get '/api/student/profile'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 when user is not a student' do
      admin_user = create(:admin_user)
      admin_token = JwtService.generate_token(admin_user)
      
      get '/api/student/profile', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
