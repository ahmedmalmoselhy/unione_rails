class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :avatar_url
      t.string :status, default: 'active'
      t.datetime :last_login_at
      t.datetime :email_verified_at
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :status
    add_index :users, :is_active
  end
end
