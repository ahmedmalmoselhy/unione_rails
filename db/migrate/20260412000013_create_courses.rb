class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :name_ar
      t.text :description
      t.integer :credit_hours, null: false
      t.integer :lecture_hours, null: false, default: 0
      t.integer :lab_hours, null: false, default: 0
      t.integer :level, null: false
      t.boolean :is_elective, default: false
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :courses, :code, unique: true
  end
end
