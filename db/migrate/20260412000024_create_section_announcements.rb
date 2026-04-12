class CreateSectionAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :section_announcements do |t|
      t.references :section, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :published_at

      t.timestamps
    end
  end
end
