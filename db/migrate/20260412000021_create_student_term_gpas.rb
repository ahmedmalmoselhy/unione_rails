class CreateStudentTermGpas < ActiveRecord::Migration[7.1]
  def change
    create_table :student_term_gpas do |t|
      t.references :student, null: false, foreign_key: true
      t.references :academic_term, null: false, foreign_key: true
      t.decimal :gpa, precision: 3, scale: 2
      t.integer :credit_hours_completed

      t.timestamps
    end

    add_index :student_term_gpas, [:student_id, :academic_term_id], unique: true
  end
end
