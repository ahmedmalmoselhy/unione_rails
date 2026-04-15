class GraphqlController < ActionController::API
  def execute
    render json: {
      success: false,
      error: 'GraphQL API is not enabled in this deployment'
    }, status: :not_implemented
  end
end
