class Webhook < ApplicationRecord
  belongs_to :user
  has_many :webhook_deliveries, dependent: :destroy

  validates :url, presence: true
  validates :secret, presence: true
end
