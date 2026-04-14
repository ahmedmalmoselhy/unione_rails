class CreateSectionTeachingAssistants < ActiveRecord::Migration[7.2]
  def change
    create_table :section_teaching_assistants do |t|
      t.references :section, null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: true
      t.references :assigned_by, null: true, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :section_teaching_assistants, [:section_id, :professor_id], unique: true
  end
end
