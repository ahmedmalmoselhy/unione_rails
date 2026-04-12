class WebhookDelivery < ApplicationRecord
  belongs_to :webhook

  enum status: { pending: 0, delivered: 1, failed: 2 }

  validates :event, presence: true
end
