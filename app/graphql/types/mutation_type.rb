module Types
  class MutationType < BaseObject
    field :sign_in, mutation: Mutations::SignIn
    field :update_my_profile, mutation: Mutations::UpdateMyProfile
  end
end
