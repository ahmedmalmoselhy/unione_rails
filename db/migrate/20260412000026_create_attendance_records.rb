class CreateAttendanceRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_records do |t|
      t.references :attendance_session, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.integer :status, null: false
      t.text :note

      t.timestamps
    end

    add_index :attendance_records, [:attendance_session_id, :student_id], unique: true
  end
end
