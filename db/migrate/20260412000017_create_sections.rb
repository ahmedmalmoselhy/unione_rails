class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: true
      t.references :academic_term, null: false, foreign_key: true
      t.integer :semester, null: false
      t.integer :capacity, null: false
      t.jsonb :schedule, default: {}

      t.timestamps
    end
  end
end
