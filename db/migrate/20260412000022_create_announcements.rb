class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :published_at
      t.boolean :is_published, default: true

      t.timestamps
    end
  end
end
