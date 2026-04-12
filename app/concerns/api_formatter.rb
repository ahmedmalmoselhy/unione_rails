module ApiFormatter
  def render_success(data: {}, message: 'Success', status: :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(message, status = :bad_request, errors: [])
    render json: {
      success: false,
      error: message,
      errors: errors
    }, status: status
  end

  def render_paginated(collection, serializer = nil, include_details: false)
    render json: {
      success: true,
      data: {
        items: collection.map { |item| serialize_item(item, serializer, include_details) },
        meta: {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      }
    }, status: :ok
  end

  private

  def serialize_item(item, serializer, include_details)
    if serializer
      serializer.new(item, include_details: include_details).to_json
    else
      item.as_json
    end
  end
end
