class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notifiable_type, null: false
      t.bigint :notifiable_id, null: false
      t.string :type, null: false
      t.jsonb :data, default: {}
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [:notifiable_type, :notifiable_id]
  end
end
