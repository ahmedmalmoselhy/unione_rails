require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { should have_many(:role_users).dependent(:destroy) }
    it { should have_many(:users).through(:role_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
  end

  describe 'callbacks' do
    it 'downcases slug before save' do
      role = create(:role, name: 'Test Role', slug: 'ADMIN_TEST')
      expect(role.slug).to eq('admin_test')
    end
  end
end
