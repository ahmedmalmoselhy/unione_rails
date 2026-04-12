class CreateWebhookDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :webhook, null: false, foreign_key: true
      t.string :event, null: false
      t.jsonb :payload, default: {}
      t.integer :status, null: false, default: 0
      t.text :response
      t.integer :attempt_count, default: 0
      t.datetime :next_retry_at

      t.timestamps
    end
  end
end
