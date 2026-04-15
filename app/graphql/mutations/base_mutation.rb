module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    private

    def current_user
      context[:current_user]
    end

    def require_authenticated_user!
      raise GraphQL::ExecutionError, 'Unauthorized' unless current_user

      current_user
    end
  end
end
