class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.references :faculty, null: false, foreign_key: true
      t.string :name, null: false
      t.string :name_ar
      t.string :code, null: false
      t.string :scope
      t.boolean :is_mandatory, default: false
      t.integer :required_credit_hours
      t.string :logo_path

      t.timestamps
    end
  end
end
