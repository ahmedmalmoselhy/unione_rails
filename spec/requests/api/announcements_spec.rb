require 'rails_helper'

RSpec.describe 'Announcements API', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:announcement) { create(:announcement, user: admin_user) }
  let(:student_user) { create(:student_user) }
  let(:token) { JwtService.generate_token(student_user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/announcements' do
    before { announcement }

    it 'returns announcements list' do
      get '/api/announcements', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
    end
  end

  describe 'POST /api/announcements/:id/read' do
    it 'marks announcement as read' do
      post "/api/announcements/#{announcement.id}/read", headers: headers

      expect(response).to have_http_status(:ok)
      expect(announcement.announcement_reads.count).to eq(1)
    end
  end
end
