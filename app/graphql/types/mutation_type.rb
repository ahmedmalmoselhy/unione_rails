module Types
  class MutationType < BaseObject
    field :sign_in, mutation: Mutations::SignIn
    field :update_my_profile, mutation: Mutations::UpdateMyProfile
    field :create_course, mutation: Mutations::CreateCourse
    field :enroll_in_section, mutation: Mutations::EnrollInSection
  end
end
