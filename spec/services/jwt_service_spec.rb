require 'rails_helper'

RSpec.describe JwtService, type: :service do
  let(:user) { create(:user, :student) }

  describe '.encode and .decode' do
    it 'encodes and decodes a payload' do
      payload = { user_id: user.id, email: user.email }
      token = JwtService.encode(payload)
      decoded = JwtService.decode(token)

      expect(decoded[:user_id]).to eq(user.id)
      expect(decoded[:email]).to eq(user.email)
    end
  end

  describe '.generate_token' do
    it 'generates a token with user info' do
      token = JwtService.generate_token(user)
      decoded = JwtService.decode(token)

      expect(decoded[:user_id]).to eq(user.id)
      expect(decoded[:email]).to eq(user.email)
      expect(decoded[:roles]).to include('student')
    end
  end

  describe '.decode with expired token' do
    it 'returns nil for expired token' do
      payload = { user_id: user.id, exp: 1.hour.ago.to_i }
      token = JWT.encode(payload, JwtService::SECRET_KEY, JwtService::ALGORITHM)

      expect(JwtService.decode(token)).to be_nil
    end
  end

  describe '.decode with invalid token' do
    it 'returns nil for tampered token' do
      token = 'invalid.token.here'

      expect(JwtService.decode(token)).to be_nil
    end
  end
end
