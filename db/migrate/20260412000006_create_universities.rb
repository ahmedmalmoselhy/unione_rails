class CreateUniversities < ActiveRecord::Migration[7.1]
  def change
    create_table :universities do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :country
      t.string :city
      t.integer :established_year
      t.string :logo_path
      t.references :president, null: true, foreign_key: { to_table: :users }
      t.string :phone
      t.string :email
      t.string :website
      t.text :address

      t.timestamps
    end

    add_index :universities, :code, unique: true
  end
end
