class CreateAcademicTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :academic_terms do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :registration_start, null: false
      t.date :registration_end, null: false
      t.boolean :is_active, default: false

      t.timestamps
    end
  end
end
