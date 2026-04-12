class CreateCoursePrerequisites < ActiveRecord::Migration[7.1]
  def change
    create_table :course_prerequisites do |t|
      t.references :course, null: false, foreign_key: true
      t.references :prerequisite, null: false, foreign_key: { to_table: :courses }

      t.timestamps
    end

    add_index :course_prerequisites, [:course_id, :prerequisite_id], unique: true
  end
end
