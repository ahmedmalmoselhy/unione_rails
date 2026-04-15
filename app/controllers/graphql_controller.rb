class GraphqlController < ApplicationController
  def execute
    result = UniOneSchema.execute(
      params[:query],
      variables: prepare_variables(params[:variables]),
      context: graphql_context,
      operation_name: params[:operationName]
    )

    render json: result
  rescue StandardError => e
    render json: {
      errors: [{ message: e.message }]
    }, status: :internal_server_error
  end

  private

  def graphql_context
    {
      current_user: current_user,
      request: request
    }
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables parameter: #{variables_param.class}"
    end
  end
end
