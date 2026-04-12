class CreateDepartmentCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :department_courses do |t|
      t.references :department, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.boolean :is_owner, default: false

      t.timestamps
    end

    add_index :department_courses, [:department_id, :course_id], unique: true
  end
end
