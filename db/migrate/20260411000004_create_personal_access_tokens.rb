class CreatePersonalAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token, null: false
      t.datetime :expires_at
      t.datetime :last_used_at
      t.datetime :revoked_at
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :personal_access_tokens, :token, unique: true
    add_index :personal_access_tokens, :revoked_at
  end
end
