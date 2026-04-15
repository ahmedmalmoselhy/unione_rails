require 'rails_helper'

RSpec.describe 'Admin Import Endpoints API', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:token) { JwtService.generate_token(admin_user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:section) { create(:section) }

  describe 'POST /api/v1/admin/students/import' do
    it 'returns 422 when file is missing' do
      post '/api/v1/admin/students/import', params: {}, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to eq('No file provided')
    end

    it 'returns 401 when unauthenticated' do
      post '/api/v1/admin/students/import', params: {}

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/admin/sections/import_grades' do
    it 'returns 422 when file is missing' do
      post '/api/v1/admin/sections/import_grades', params: { section_id: section.id }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to eq('No file provided')
    end
  end
end
