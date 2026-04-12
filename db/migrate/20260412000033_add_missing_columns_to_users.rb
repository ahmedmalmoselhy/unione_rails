class AddMissingColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :national_id, :string
    add_column :users, :gender, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :must_change_password, :boolean, default: false
    add_column :users, :deleted_at, :datetime
    add_column :users, :avatar_path, :string
    
    remove_column :users, :avatar_url, :string
    remove_column :users, :status, :string

    add_index :users, :national_id, unique: true
    add_index :users, :deleted_at
  end
end
