class StudentImportService
  attr_reader :errors, :imported_count, :failed_count

  def initialize
    @errors = []
    @imported_count = 0
    @failed_count = 0
  end

  # Import students from CSV data
  # Expected format: student_number,first_name,last_name,email,faculty_code,department_code,academic_year
  def import_from_csv(csv_data, faculty_id, department_id)
    rows = CSV.parse(csv_data, headers: true)
    
    rows.each do |row|
      import_student(row, faculty_id, department_id)
    end

    {
      success: @failed_count.zero?,
      imported: @imported_count,
      failed: @failed_count,
      errors: @errors
    }
  end

  # Import students from array of hashes
  def import_from_array(students_data, faculty_id, department_id)
    students_data.each do |student_data|
      import_student_data(student_data, faculty_id, department_id)
    end

    {
      success: @failed_count.zero?,
      imported: @imported_count,
      failed: @failed_count,
      errors: @errors
    }
  end

  private

  def import_student(row, faculty_id, department_id)
    student_data = {
      student_number: row['student_number'],
      first_name: row['first_name'],
      last_name: row['last_name'],
      email: row['email'],
      academic_year: row['academic_year'].to_i,
      faculty_id: faculty_id,
      department_id: department_id
    }

    import_student_data(student_data, faculty_id, department_id)
  end

  def import_student_data(student_data, faculty_id, department_id)
    # Check if student already exists
    if ::Student.exists?(student_number: student_data[:student_number])
      @errors << "Student #{student_data[:student_number]} already exists"
      @failed_count += 1
      return
    end

    # Create or find user
    user = ::User.find_or_initialize_by(email: student_data[:email])
    
    if user.new_record?
      user.assign_attributes(
        national_id: generate_national_id,
        first_name: student_data[:first_name],
        last_name: student_data[:last_name],
        password: SecureRandom.hex(8),
        is_active: true
      )
      
      unless user.save
        @errors << "Failed to create user for #{student_data[:email]}: #{user.errors.full_messages.join(', ')}"
        @failed_count += 1
        return
      end

      # Assign student role
      student_role = ::Role.find_or_create_by(slug: 'student')
      user.roles << student_role
    end

    # Create student
    student = ::Student.new(
      user: user,
      student_number: student_data[:student_number],
      faculty_id: faculty_id,
      department_id: department_id,
      academic_year: student_data[:academic_year] || 1,
      semester: 1,
      enrollment_status: :active,
      gpa: 0.0,
      academic_standing: :good,
      enrolled_at: Date.current
    )

    if student.save
      @imported_count += 1
    else
      @errors << "Failed to create student #{student_data[:student_number]}: #{student.errors.full_messages.join(', ')}"
      @failed_count += 1
    end
  end

  def generate_national_id
    loop do
      national_id = "NID#{SecureRandom.random_number(10**10).to_s.rjust(10, '0')}"
      break national_id unless ::User.exists?(national_id: national_id)
    end
  end
end
