class CreateCache < ActiveRecord::Migration[7.1]
  def change
    create_table :cache do |t|
      t.string :key, null: false
      t.binary :value, null: true
      t.integer :expires_at, null: true

      t.timestamps
    end

    add_index :cache, :key, unique: true
  end
end
