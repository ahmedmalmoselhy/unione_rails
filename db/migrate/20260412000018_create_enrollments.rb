class CreateEnrollments < ActiveRecord::Migration[7.1]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :academic_term, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :registered_at, null: false
      t.datetime :dropped_at

      t.timestamps
    end

    add_index :enrollments, [:student_id, :status]
  end
end
