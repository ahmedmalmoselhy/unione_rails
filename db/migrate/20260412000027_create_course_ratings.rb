class CreateCourseRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :course_ratings do |t|
      t.references :enrollment, null: false, foreign_key: true, index: { unique: true }
      t.integer :rating, null: false
      t.text :feedback
      t.datetime :submitted_at, null: false

      t.timestamps
    end
  end
end
