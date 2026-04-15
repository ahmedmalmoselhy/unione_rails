module Mutations
  class UpdateMyProfile < BaseMutation
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :phone, String, required: false

    type Types::UserPayloadType

    def resolve(first_name: nil, last_name: nil, phone: nil)
      user = require_authenticated_user!
      attributes = {
        first_name: first_name,
        last_name: last_name,
        phone: phone
      }.compact

      if attributes.empty?
        return {
          user: nil,
          errors: ['Provide at least one field to update']
        }
      end

      if user.update(attributes)
        {
          user: user,
          errors: []
        }
      else
        {
          user: nil,
          errors: user.errors.full_messages
        }
      end
    end
  end
end
