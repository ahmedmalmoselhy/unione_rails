class CreateStudentDepartmentHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :student_department_histories do |t|
      t.references :student, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.integer :academic_year, null: false
      t.integer :semester, null: false
      t.string :reason

      t.timestamps
    end
  end
end
