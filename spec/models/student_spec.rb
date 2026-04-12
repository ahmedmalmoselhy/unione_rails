require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:faculty) }
    it { should belong_to(:department) }
    it { should have_many(:enrollments).dependent(:destroy) }
    it { should have_many(:attendance_records).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:enrollment_status).with_values(active: 0, graduated: 1, suspended: 2) }
    it { should define_enum_for(:academic_standing).with_values(excellent: 0, good: 1, probation: 2, suspension: 3) }
  end

  describe 'validations' do
    it { should validate_presence_of(:student_number) }
    it { should validate_uniqueness_of(:student_number).case_insensitive }
  end

  describe 'factory' do
    it 'creates a valid student' do
      student = build(:student)
      expect(student).to be_valid
    end
  end
end
