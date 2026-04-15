class CreateGroupProjectsTables < ActiveRecord::Migration[7.1]
  def change
    create_table :group_projects do |t|
      t.references :section, null: false, foreign_key: true
      t.references :created_by_user, null: true, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.datetime :due_at
      t.integer :max_members, default: 5, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :group_projects, [:section_id, :is_active]

    create_table :group_project_members do |t|
      t.references :group_project, null: false, foreign_key: { on_delete: :cascade }
      t.references :student, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :joined_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps

      t.index [:group_project_id, :student_id], unique: true, name: 'idx_group_project_members_unique'
    end
  end
end
