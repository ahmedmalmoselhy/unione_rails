class CreateWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :webhooks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      t.string :secret, null: false
      t.jsonb :events, default: []
      t.boolean :is_active, default: true
      t.integer :failure_count, default: 0
      t.datetime :last_triggered_at

      t.timestamps
    end
  end
end
