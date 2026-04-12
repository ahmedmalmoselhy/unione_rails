class CreateEnrollmentWaitlists < ActiveRecord::Migration[7.1]
  def change
    create_table :enrollment_waitlists do |t|
      t.references :student, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :academic_term, null: false, foreign_key: true
      t.integer :position, null: false
      t.decimal :priority_score, precision: 4, scale: 2
      t.datetime :requested_at, null: false

      t.timestamps
    end
  end
end
