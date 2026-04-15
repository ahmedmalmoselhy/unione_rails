module Mutations
  class SignIn < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    type Types::AuthPayloadType

    def resolve(email:, password:)
      service = AuthenticationService.new
      result = service.authenticate(
        email,
        password,
        ip_address: context[:request]&.remote_ip,
        user_agent: context[:request]&.user_agent
      )

      if result
        {
          token: result[:token],
          user: result[:user],
          errors: []
        }
      else
        {
          token: nil,
          user: nil,
          errors: service.errors
        }
      end
    end
  end
end
