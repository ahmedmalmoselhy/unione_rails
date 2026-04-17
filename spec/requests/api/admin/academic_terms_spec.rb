require 'rails_helper'

RSpec.describe "Api::Admin::AcademicTerms", type: :request do
  let(:admin) { create(:admin_user) }
  let(:token) { JwtService.generate_token(admin) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /api/v1/admin/terms" do
    it "returns all academic terms" do
      create_list(:academic_term, 3)
      get "/api/v1/admin/terms", headers: headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['academic_terms'].length).to eq(3)
    end
  end

  describe "POST /api/v1/admin/terms" do
    let(:valid_params) do
      {
        academic_term: {
          name: 'Spring 2026',
          start_date: '2026-02-01',
          end_date: '2026-06-30',
          registration_start: '2026-01-01',
          registration_end: '2026-01-31',
          is_active: false
        }
      }
    end

    it "creates a new academic term" do
      expect {
        post "/api/v1/admin/terms", params: valid_params, headers: headers
      }.to change(AcademicTerm, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "PATCH /api/v1/admin/terms/:id" do
    let(:academic_term) { create(:academic_term) }

    it "updates the academic term" do
      patch "/api/v1/admin/terms/#{academic_term.id}", 
            params: { academic_term: { name: 'Updated Term Name' } }, 
            headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(academic_term.reload.name).to eq('Updated Term Name')
    end
  end

  describe "POST /api/v1/admin/terms/:id/activate" do
    let(:academic_term) { create(:academic_term, is_active: false) }

    it "activates the academic term" do
      post "/api/v1/admin/terms/#{academic_term.id}/activate", headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(academic_term.reload.is_active).to be true
    end
  end
end
