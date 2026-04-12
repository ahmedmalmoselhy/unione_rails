require 'rails_helper'

RSpec.describe Professor, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:department) }
    it { should have_many(:sections).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:staff_number) }
    it { should validate_uniqueness_of(:staff_number).case_insensitive }
    it { should validate_presence_of(:academic_rank) }
  end

  describe 'factory' do
    it 'creates a valid professor' do
      professor = build(:professor)
      expect(professor).to be_valid
    end
  end
end
