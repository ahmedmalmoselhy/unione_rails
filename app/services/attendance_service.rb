class AttendanceService
  # Create a new attendance session
  def create_session(section, date:, session_number:)
    AttendanceSession.create!(
      section: section,
      date: date,
      session_number: session_number,
      status: :open
    )
  end

  # Record attendance for a student
  def record_attendance(session, student, status:, note: nil)
    AttendanceRecord.find_or_create_by!(
      attendance_session: session,
      student: student
    ).update!(status: status, note: note)
  end

  # Bulk record attendance for multiple students
  def bulk_record_attendance(session, attendance_data)
    # attendance_data: [{ student_id: 1, status: 'present', note: nil }, ...]
    results = { success: 0, failed: 0, errors: [] }

    attendance_data.each do |data|
      student = Student.find_by(id: data[:student_id])
      next unless student

      begin
        record_attendance(session, student, status: data[:status], note: data[:note])
        results[:success] += 1
      rescue => e
        results[:failed] += 1
        results[:errors] << "Student #{student.student_number}: #{e.message}"
      end
    end

    results
  end

  # Close an attendance session
  def close_session(session)
    session.update!(status: :closed)
  end

  # Get attendance statistics for a section
  def attendance_statistics(section)
    sessions = section.attendance_sessions
    total_sessions = sessions.count
    closed_sessions = sessions.where(status: :closed).count

    students = section.students
    student_stats = students.map do |student|
      records = AttendanceRecord.joins(:attendance_session)
                               .where(attendance_sessions: { section_id: section.id },
                                      student_id: student.id)

      total = records.count
      present = records.where(status: :present).count
      absent = records.where(status: :absent).count
      late = records.where(status: :late).count

      {
        student_number: student.student_number,
        name: student.user.full_name,
        attendance_rate: total.positive? ? ((present + late) / total.to_f * 100).round(2) : 0,
        present: present,
        absent: absent,
        late: late,
        total: total
      }
    end

    {
      total_sessions: total_sessions,
      closed_sessions: closed_sessions,
      open_sessions: total_sessions - closed_sessions,
      students: student_stats
    }
  end
end
