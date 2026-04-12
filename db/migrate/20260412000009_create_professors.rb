class CreateProfessors < ActiveRecord::Migration[7.1]
  def change
    create_table :professors do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :staff_number, null: false
      t.references :department, null: false, foreign_key: true
      t.string :specialization
      t.string :academic_rank, null: false
      t.string :office_location
      t.date :hired_at, null: false

      t.timestamps
    end

    add_index :professors, :staff_number, unique: true
  end
end
