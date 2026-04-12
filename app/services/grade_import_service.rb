class GradeImportService
  attr_reader :errors, :imported_count, :failed_count

  def initialize
    @errors = []
    @imported_count = 0
    @failed_count = 0
  end

  # Import grades from CSV data
  # Expected format: student_number,course_code,points,letter_grade
  def import_from_csv(csv_data, section_id, academic_term_id)
    rows = CSV.parse(csv_data, headers: true)
    
    rows.each do |row|
      import_grade(row, section_id, academic_term_id)
    end

    {
      success: @failed_count.zero?,
      imported: @imported_count,
      failed: @failed_count,
      errors: @errors
    }
  end

  # Import grades from array of hashes
  def import_from_array(grades_data, section_id, academic_term_id)
    grades_data.each do |grade_data|
      import_grade_data(grade_data, section_id, academic_term_id)
    end

    {
      success: @failed_count.zero?,
      imported: @imported_count,
      failed: @failed_count,
      errors: @errors
    }
  end

  private

  def import_grade(row, section_id, academic_term_id)
    grade_data = {
      student_number: row['student_number'],
      course_code: row['course_code'],
      points: row['points'].to_i,
      letter_grade: row['letter_grade']
    }

    import_grade_data(grade_data, section_id, academic_term_id)
  end

  def import_grade_data(grade_data, section_id, academic_term_id)
    # Find enrollment
    enrollment = ::Enrollment.joins(:student, :section)
                            .find_by(
                              students: { student_number: grade_data[:student_number] },
                              section_id: section_id,
                              academic_term_id: academic_term_id
                            )

    unless enrollment
      @errors << "Enrollment not found for student #{grade_data[:student_number]} in section #{section_id}"
      @failed_count += 1
      return
    end

    # Create or update grade
    grade = enrollment.grade || ::Grade.new(enrollment: enrollment)
    
    grade.assign_attributes(
      points: grade_data[:points],
      letter_grade: grade_data[:letter_grade],
      status: :complete
    )

    if grade.save
      @imported_count += 1
      
      # Trigger notifications
      SendGradeNotificationJob.perform_later(grade.id)
    else
      @errors << "Failed to create grade for #{grade_data[:student_number]}: #{grade.errors.full_messages.join(', ')}"
      @failed_count += 1
    end
  end
end
