require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:role_users).dependent(:destroy) }
    it { should have_many(:roles).through(:role_users) }
    it { should have_many(:personal_access_tokens).dependent(:destroy) }
    it { should have_many(:password_reset_tokens).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:password).is_at_least(6) }

    describe 'email uniqueness' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }
      subject { build(:user, email: 'test@example.com') }

      it 'does not allow duplicate emails' do
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include('has already been taken')
      end
    end
  end

  describe 'callbacks' do
    it 'downcases email before save' do
      user = create(:user, email: 'Test@Example.COM')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns full name' do
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#has_role?' do
    let(:user) { create(:user, :student) }

    it 'returns true for assigned role' do
      expect(user.has_role?('student')).to be true
    end

    it 'returns false for unassigned role' do
      expect(user.has_role?('admin')).to be false
    end
  end

  describe '#role_slugs' do
    let(:user) { create(:user, :student) }

    it 'returns array of role slugs' do
      expect(user.role_slugs).to include('student')
    end
  end

  describe '#admin?' do
    let(:admin) { create(:user, :admin) }
    let(:student) { create(:user, :student) }

    it 'returns true for admin' do
      expect(admin.admin?).to be true
    end

    it 'returns false for non-admin' do
      expect(student.admin?).to be false
    end
  end

  describe 'password encryption' do
    let(:user) { create(:user, password: 'password123') }

    it 'stores encrypted password' do
      expect(user.password_digest).not_to eq('password123')
    end

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      expect(user.authenticate('wrongpassword')).to be false
    end
  end

  describe '.active scope' do
    let!(:active_user) { create(:user, is_active: true) }
    let!(:inactive_user) { create(:user, :inactive) }

    it 'returns only active users' do
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end
  end
end
