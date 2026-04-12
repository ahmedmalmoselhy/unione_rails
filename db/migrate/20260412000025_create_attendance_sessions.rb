class CreateAttendanceSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_sessions do |t|
      t.references :section, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :session_number, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
