class CreateUniversityVicePresidents < ActiveRecord::Migration[7.1]
  def change
    create_table :university_vice_presidents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :university, null: false, foreign_key: true
      t.string :department, null: false
      t.date :appointed_at, null: false

      t.timestamps
    end
  end
end
