require 'rails_helper'
require 'tempfile'

RSpec.describe 'Professor Grade Import API', type: :request do
  let(:professor_user) { create(:professor_user) }
  let(:professor) { create(:professor, user: professor_user) }
  let(:course) { create(:course, code: 'CS101') }
  let(:academic_term) { create(:academic_term) }
  let(:section) { create(:section, professor: professor, course: course, academic_term: academic_term) }
  let(:student) { create(:student, student_number: 'STD0001') }
  let!(:enrollment) { create(:enrollment, student: student, section: section, academic_term: academic_term) }

  let(:token) { JwtService.generate_token(professor_user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  def build_grade_import_file(rows)
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: 'Grades') do |sheet|
      sheet.add_row %w[student_number course_code points letter_grade]
      rows.each do |row|
        sheet.add_row [row[:student_number], row[:course_code], row[:points], row[:letter_grade]]
      end
    end

    tempfile = Tempfile.new(['grade_import', '.xlsx'])
    tempfile.binmode
    tempfile.write(package.to_stream.read)
    tempfile.rewind

    Rack::Test::UploadedFile.new(
      tempfile.path,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      true,
      original_filename: 'grade_import.xlsx'
    )
  ensure
    tempfile&.close
  end

  describe 'POST /api/professor/sections/:section_id/grades/import' do
    it 'imports grades for professor-owned section' do
      file = build_grade_import_file([
        {
          student_number: student.student_number,
          course_code: section.course.code,
          points: 91,
          letter_grade: 'A'
        }
      ])

      post "/api/professor/sections/#{section.id}/grades/import", params: { file: file }, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data']['imported']).to eq(1)
      expect(json['data']['failed']).to eq(0)

      grade = enrollment.reload.grade
      expect(grade).to be_present
      expect(grade.points).to eq(91)
      expect(grade.letter_grade).to eq('A')
    end

    it 'returns 422 when file is missing' do
      post "/api/professor/sections/#{section.id}/grades/import", params: {}, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to eq('No file provided')
    end

    it 'returns 401 when unauthenticated' do
      post "/api/professor/sections/#{section.id}/grades/import", params: {}

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
