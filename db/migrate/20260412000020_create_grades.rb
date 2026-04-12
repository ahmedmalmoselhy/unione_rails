class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
      t.references :enrollment, null: false, foreign_key: true, index: { unique: true }
      t.integer :points
      t.string :letter_grade
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
