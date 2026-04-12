class CreateRoleUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :role_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :scope_entity, polymorphic: true

      t.timestamps
    end

    add_index :role_users, [:user_id, :role_id], unique: true
  end
end
