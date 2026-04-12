require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'associations' do
    it { should have_many(:department_courses).dependent(:destroy) }
    it { should have_many(:departments).through(:department_courses) }
    it { should have_many(:sections).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:credit_hours) }
    it { should validate_numericality_of(:credit_hours).is_greater_than(0) }
  end

  describe 'factory' do
    it 'creates a valid course' do
      course = build(:course)
      expect(course).to be_valid
    end
  end
end
