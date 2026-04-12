class WebhookDeliveryJob < ApplicationJob
  queue_as :webhooks

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(webhook_id, event, payload)
    webhook = Webhook.find_by(id: webhook_id)
    return unless webhook&.is_active

    # Create delivery record
    delivery = WebhookDelivery.create!(
      webhook: webhook,
      event: event,
      payload: payload,
      status: :pending
    )

    # Prepare HTTP request
    uri = URI(webhook.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Webhook-Signature' => generate_signature(webhook.secret, payload),
      'X-Webhook-Event' => event,
      'X-Webhook-Delivery-Id' => delivery.id.to_s
    })
    request.body = payload.to_json

    # Send request
    response = http.request(request)

    # Update delivery status
    if response.is_a?(Net::HTTPSuccess)
      delivery.update!(
        status: :delivered,
        response: response.body,
        attempt_count: delivery.attempt_count + 1
      )
    else
      delivery.update!(
        status: :failed,
        response: response.body,
        attempt_count: delivery.attempt_count + 1,
        next_retry_at: 1.hour.from_now
      )

      # Increment webhook failure count
      webhook.increment!(:failure_count)
    end

    # Update webhook last triggered
    webhook.update!(last_triggered_at: DateTime.current)
  end

  private

  def generate_signature(secret, payload)
    OpenSSL::HMAC.hexdigest('sha256', secret, payload.to_json)
  end
end
