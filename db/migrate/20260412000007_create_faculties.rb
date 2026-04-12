class CreateFaculties < ActiveRecord::Migration[7.1]
  def change
    create_table :faculties do |t|
      t.references :university, null: false, foreign_key: true
      t.string :name, null: false
      t.string :name_ar
      t.string :code, null: false
      t.string :logo_path

      t.timestamps
    end
  end
end
