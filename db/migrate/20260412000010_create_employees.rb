class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :staff_number, null: false
      t.references :department, null: false, foreign_key: true
      t.string :position, null: false
      t.date :hired_at, null: false

      t.timestamps
    end

    add_index :employees, :staff_number, unique: true
  end
end
