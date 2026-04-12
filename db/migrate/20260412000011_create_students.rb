class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :student_number, null: false
      t.references :faculty, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.integer :academic_year, null: false
      t.integer :semester, null: false
      t.integer :enrollment_status, null: false, default: 0
      t.decimal :gpa, precision: 3, scale: 2, default: 0.0
      t.integer :academic_standing, null: false, default: 0
      t.date :enrolled_at, null: false
      t.date :graduated_at

      t.timestamps
    end

    add_index :students, :student_number, unique: true
  end
end
