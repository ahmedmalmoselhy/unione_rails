# Clear existing data (in correct order to avoid foreign key issues)
puts "Clearing existing data..."
[Notification, WebhookDelivery, Webhook, AuditLog, CourseRating, AttendanceRecord, 
 AttendanceSession, SectionAnnouncement, AnnouncementRead, Announcement, Grade, 
 StudentTermGpa, EnrollmentWaitlist, Enrollment, Section, AcademicTerm, 
 CoursePrerequisite, DepartmentCourse, Course, StudentDepartmentHistory, Student, 
 Employee, Professor, UniversityVicePresident, Department, Faculty, University,
 RoleUser, PersonalAccessToken, PasswordResetToken].each do |model|
  model.delete_all
end

User.delete_all
Role.delete_all

puts "Database cleared"

# ============================================================
# ROLES
# ============================================================
puts "Creating roles..."
roles = [
  { name: 'Admin', slug: 'admin', description: 'Full system access' },
  { name: 'Faculty Admin', slug: 'faculty_admin', description: 'Faculty-level management' },
  { name: 'Department Admin', slug: 'department_admin', description: 'Department-level management' },
  { name: 'Professor', slug: 'professor', description: 'Course management and grading' },
  { name: 'Student', slug: 'student', description: 'Course enrollment and grades' },
  { name: 'Employee', slug: 'employee', description: 'Administrative tasks' }
]

roles.each do |role_attrs|
  Role.create!(role_attrs)
end

puts "Created #{Role.count} roles"

# ============================================================
# UNIVERSITY
# ============================================================
puts "Creating university..."
university = University.create!(
  name: 'King Abdulaziz University',
  code: 'KAU',
  country: 'Saudi Arabia',
  city: 'Jeddah',
  established_year: 1967,
  phone: '+966-12-640-0000',
  email: 'info@kau.edu.sa',
  website: 'https://www.kau.edu.sa',
  address: 'Al Ezzawiya, Jeddah 21589, Saudi Arabia'
)

puts "Created university: #{university.name}"

# ============================================================
# FACULTIES
# ============================================================
puts "Creating faculties..."
faculty_engineering = Faculty.create!(
  university: university,
  name: 'Faculty of Engineering',
  name_ar: 'كلية الهندسة',
  code: 'ENG'
)

faculty_science = Faculty.create!(
  university: university,
  name: 'Faculty of Science',
  name_ar: 'كلية العلوم',
  code: 'SCI'
)

faculty_computing = Faculty.create!(
  university: university,
  name: 'Faculty of Computing and Information Technology',
  name_ar: 'كلية الحوسبة وتكنولوجيا المعلومات',
  code: 'FCIT'
)

puts "Created #{Faculty.count} faculties"

# ============================================================
# DEPARTMENTS
# ============================================================
puts "Creating departments..."
# Engineering departments
dept_computer_eng = Department.create!(
  faculty: faculty_engineering,
  name: 'Computer Engineering Department',
  name_ar: 'قسم هندسة الحاسب',
  code: 'CE',
  is_mandatory: true,
  required_credit_hours: 136
)

dept_electrical_eng = Department.create!(
  faculty: faculty_engineering,
  name: 'Electrical Engineering Department',
  name_ar: 'قسم الهندسة الكهربائية',
  code: 'EE',
  is_mandatory: true,
  required_credit_hours: 140
)

dept_mechanical_eng = Department.create!(
  faculty: faculty_engineering,
  name: 'Mechanical Engineering Department',
  name_ar: 'قسم الهندسة الميكانيكية',
  code: 'ME',
  is_mandatory: true,
  required_credit_hours: 138
)

# Science departments
dept_computer_science = Department.create!(
  faculty: faculty_science,
  name: 'Computer Science Department',
  name_ar: 'قسم علوم الحاسب',
  code: 'CS',
  is_mandatory: true,
  required_credit_hours: 130
)

dept_mathematics = Department.create!(
  faculty: faculty_science,
  name: 'Mathematics Department',
  name_ar: 'قسم الرياضيات',
  code: 'MATH',
  is_mandatory: false,
  required_credit_hours: 126
)

# Computing departments
dept_information_tech = Department.create!(
  faculty: faculty_computing,
  name: 'Information Technology Department',
  name_ar: 'قسم تكنولوجيا المعلومات',
  code: 'IT',
  is_mandatory: true,
  required_credit_hours: 132
)

dept_information_systems = Department.create!(
  faculty: faculty_computing,
  name: 'Information Systems Department',
  name_ar: 'قسم نظم المعلومات',
  code: 'IS',
  is_mandatory: true,
  required_credit_hours: 130
)

puts "Created #{Department.count} departments"

# ============================================================
# USERS
# ============================================================
puts "Creating users..."

# Admin user
admin_user = User.create!(
  national_id: '1000000001',
  first_name: 'Ahmed',
  last_name: 'Al-Ghamdi',
  email: 'admin@unione.com',
  password: 'password123',
  phone: '+966-50-123-4567',
  gender: 'male',
  date_of_birth: Date.new(1980, 5, 15),
  is_active: true
)

# Student users
student1_user = User.create!(
  national_id: '1000000002',
  first_name: 'Mohammed',
  last_name: 'Al-Zahrani',
  email: 'student@unione.com',
  password: 'password123',
  phone: '+966-50-234-5678',
  gender: 'male',
  date_of_birth: Date.new(2001, 3, 20),
  is_active: true
)

student2_user = User.create!(
  national_id: '1000000003',
  first_name: 'Fatima',
  last_name: 'Al-Qahtani',
  email: 'fatima.student@unione.com',
  password: 'password123',
  phone: '+966-50-345-6789',
  gender: 'female',
  date_of_birth: Date.new(2002, 7, 10),
  is_active: true
)

student3_user = User.create!(
  national_id: '1000000004',
  first_name: 'Omar',
  last_name: 'Al-Harbi',
  email: 'omar.student@unione.com',
  password: 'password123',
  phone: '+966-50-456-7890',
  gender: 'male',
  date_of_birth: Date.new(2001, 11, 5),
  is_active: true
)

# Professor users
professor1_user = User.create!(
  national_id: '1000000005',
  first_name: 'Dr. Khalid',
  last_name: 'Al-Otaibi',
  email: 'professor@unione.com',
  password: 'password123',
  phone: '+966-50-567-8901',
  gender: 'male',
  date_of_birth: Date.new(1975, 1, 25),
  is_active: true
)

professor2_user = User.create!(
  national_id: '1000000006',
  first_name: 'Dr. Sara',
  last_name: 'Al-Shehri',
  email: 'sara.professor@unione.com',
  password: 'password123',
  phone: '+966-50-678-9012',
  gender: 'female',
  date_of_birth: Date.new(1978, 9, 12),
  is_active: true
)

# Employee user
employee_user = User.create!(
  national_id: '1000000007',
  first_name: 'Abdullah',
  last_name: 'Al-Dosari',
  email: 'employee@unione.com',
  password: 'password123',
  phone: '+966-50-789-0123',
  gender: 'male',
  date_of_birth: Date.new(1990, 4, 8),
  is_active: true
)

puts "Created #{User.count} users"

# ============================================================
# ROLE ASSIGNMENTS
# ============================================================
puts "Assigning roles..."
RoleUser.create!(user: admin_user, role: Role.find_by(slug: 'admin'))
RoleUser.create!(user: student1_user, role: Role.find_by(slug: 'student'))
RoleUser.create!(user: student2_user, role: Role.find_by(slug: 'student'))
RoleUser.create!(user: student3_user, role: Role.find_by(slug: 'student'))
RoleUser.create!(user: professor1_user, role: Role.find_by(slug: 'professor'))
RoleUser.create!(user: professor2_user, role: Role.find_by(slug: 'professor'))
RoleUser.create!(user: employee_user, role: Role.find_by(slug: 'employee'))

puts "Assigned #{RoleUser.count} roles"

# ============================================================
# PROFESSORS
# ============================================================
puts "Creating professors..."
professor1 = Professor.create!(
  user: professor1_user,
  staff_number: 'PROF001',
  department: dept_computer_eng,
  specialization: 'Artificial Intelligence',
  academic_rank: 'Associate Professor',
  office_location: 'ENG Building, Room 301',
  hired_at: Date.new(2010, 9, 1)
)

professor2 = Professor.create!(
  user: professor2_user,
  staff_number: 'PROF002',
  department: dept_computer_science,
  specialization: 'Database Systems',
  academic_rank: 'Assistant Professor',
  office_location: 'SCI Building, Room 205',
  hired_at: Date.new(2015, 1, 15)
)

puts "Created #{Professor.count} professors"

# ============================================================
# STUDENTS
# ============================================================
puts "Creating students..."
student1 = Student.create!(
  user: student1_user,
  student_number: 'STU2020001',
  faculty: faculty_engineering,
  department: dept_computer_eng,
  academic_year: 4,
  semester: 1,
  enrollment_status: :active,
  gpa: 3.75,
  academic_standing: :good,
  enrolled_at: Date.new(2020, 9, 1)
)

student2 = Student.create!(
  user: student2_user,
  student_number: 'STU2021002',
  faculty: faculty_computing,
  department: dept_information_tech,
  academic_year: 3,
  semester: 1,
  enrollment_status: :active,
  gpa: 3.92,
  academic_standing: :good,
  enrolled_at: Date.new(2021, 9, 1)
)

student3 = Student.create!(
  user: student3_user,
  student_number: 'STU2021003',
  faculty: faculty_science,
  department: dept_computer_science,
  academic_year: 3,
  semester: 1,
  enrollment_status: :active,
  gpa: 2.85,
  academic_standing: :good,
  enrolled_at: Date.new(2021, 9, 1)
)

puts "Created #{Student.count} students"

# ============================================================
# EMPLOYEES
# ============================================================
puts "Creating employees..."
employee = Employee.create!(
  user: employee_user,
  staff_number: 'EMP001',
  department: dept_information_tech,
  position: 'IT Coordinator',
  hired_at: Date.new(2019, 3, 1)
)

puts "Created #{Employee.count} employees"

# ============================================================
# COURSES
# ============================================================
puts "Creating courses..."
course_data_structure = Course.create!(
  code: 'CS201',
  name: 'Data Structures and Algorithms',
  name_ar: 'هياكل البيانات والخوارزميات',
  description: 'Introduction to data structures including arrays, linked lists, trees, and graphs. Algorithm analysis and design.',
  credit_hours: 3,
  lecture_hours: 3,
  lab_hours: 1,
  level: 200,
  is_elective: false
)

course_db_systems = Course.create!(
  code: 'CS301',
  name: 'Database Systems',
  name_ar: 'نظم قواعد البيانات',
  description: 'Relational database design, SQL, normalization, transaction management, and database administration.',
  credit_hours: 3,
  lecture_hours: 3,
  lab_hours: 1,
  level: 300,
  is_elective: false
)

course_ai_intro = Course.create!(
  code: 'CS401',
  name: 'Introduction to Artificial Intelligence',
  name_ar: 'مقدمة في الذكاء الاصطناعي',
  description: 'Fundamentals of AI including search algorithms, knowledge representation, machine learning basics.',
  credit_hours: 3,
  lecture_hours: 3,
  lab_hours: 0,
  level: 400,
  is_elective: true
)

course_programming1 = Course.create!(
  code: 'CS101',
  name: 'Programming Fundamentals',
  name_ar: 'أساسيات البرمجة',
  description: 'Introduction to programming concepts using Python. Variables, loops, functions, and basic OOP.',
  credit_hours: 4,
  lecture_hours: 3,
  lab_hours: 2,
  level: 100,
  is_elective: false
)

course_software_eng = Course.create!(
  code: 'CS350',
  name: 'Software Engineering',
  name_ar: 'هندسة البرمجيات',
  description: 'Software development lifecycle, requirements engineering, design patterns, testing, and project management.',
  credit_hours: 3,
  lecture_hours: 3,
  lab_hours: 1,
  level: 300,
  is_elective: false
)

course_web_dev = Course.create!(
  code: 'CS360',
  name: 'Web Development',
  name_ar: 'تطوير الويب',
  description: 'Modern web development with HTML, CSS, JavaScript, and frameworks. RESTful APIs and frontend architecture.',
  credit_hours: 3,
  lecture_hours: 2,
  lab_hours: 2,
  level: 300,
  is_elective: true
)

puts "Created #{Course.count} courses"

# ============================================================
# DEPARTMENT-COURSE RELATIONSHIPS
# ============================================================
puts "Creating department-course relationships..."
DepartmentCourse.create!(department: dept_computer_science, course: course_data_structure, is_owner: true)
DepartmentCourse.create!(department: dept_computer_science, course: course_db_systems, is_owner: true)
DepartmentCourse.create!(department: dept_computer_science, course: course_ai_intro, is_owner: true)
DepartmentCourse.create!(department: dept_computer_science, course: course_programming1, is_owner: true)
DepartmentCourse.create!(department: dept_computer_science, course: course_software_eng, is_owner: true)
DepartmentCourse.create!(department: dept_computer_eng, course: course_data_structure, is_owner: false)
DepartmentCourse.create!(department: dept_information_tech, course: course_web_dev, is_owner: true)

puts "Created #{DepartmentCourse.count} department-course relationships"

# ============================================================
# COURSE PREREQUISITES
# ============================================================
puts "Creating course prerequisites..."
CoursePrerequisite.create!(course: course_data_structure, prerequisite: course_programming1)
CoursePrerequisite.create!(course: course_db_systems, prerequisite: course_data_structure)
CoursePrerequisite.create!(course: course_ai_intro, prerequisite: course_data_structure)
CoursePrerequisite.create!(course: course_software_eng, prerequisite: course_data_structure)

puts "Created #{CoursePrerequisite.count} prerequisites"

# ============================================================
# ACADEMIC TERMS
# ============================================================
puts "Creating academic terms..."
term_fall_2024 = AcademicTerm.create!(
  name: 'Fall 2024',
  start_date: Date.new(2024, 8, 25),
  end_date: Date.new(2025, 1, 15),
  registration_start: Date.new(2024, 7, 1),
  registration_end: Date.new(2024, 8, 20),
  is_active: false
)

term_spring_2025 = AcademicTerm.create!(
  name: 'Spring 2025',
  start_date: Date.new(2025, 1, 20),
  end_date: Date.new(2025, 5, 30),
  registration_start: Date.new(2024, 12, 1),
  registration_end: Date.new(2025, 1, 15),
  is_active: true
)

term_fall_2025 = AcademicTerm.create!(
  name: 'Fall 2025',
  start_date: Date.new(2025, 8, 25),
  end_date: Date.new(2026, 1, 15),
  registration_start: Date.new(2025, 7, 1),
  registration_end: Date.new(2025, 8, 20),
  is_active: false
)

puts "Created #{AcademicTerm.count} academic terms"

# ============================================================
# SECTIONS
# ============================================================
puts "Creating sections..."
section_data_structure = Section.create!(
  course: course_data_structure,
  professor: professor1,
  academic_term: term_spring_2025,
  semester: 1,
  capacity: 40,
  schedule: { days: [1, 3, 5], start_time: '09:00', end_time: '10:30', location: 'ENG-101' }
)

section_db_systems = Section.create!(
  course: course_db_systems,
  professor: professor2,
  academic_term: term_spring_2025,
  semester: 1,
  capacity: 35,
  schedule: { days: [2, 4], start_time: '11:00', end_time: '12:30', location: 'SCI-205' }
)

section_programming = Section.create!(
  course: course_programming1,
  professor: professor1,
  academic_term: term_spring_2025,
  semester: 1,
  capacity: 45,
  schedule: { days: [1, 3], start_time: '13:00', end_time: '14:30', location: 'CS-LAB-1' }
)

section_web_dev = Section.create!(
  course: course_web_dev,
  professor: professor2,
  academic_term: term_spring_2025,
  semester: 1,
  capacity: 30,
  schedule: { days: [2, 4], start_time: '15:00', end_time: '16:30', location: 'FCIT-LAB-2' }
)

puts "Created #{Section.count} sections"

# ============================================================
# ENROLLMENTS
# ============================================================
puts "Creating enrollments..."
enrollments = [
  { student: student1, section: section_data_structure, term: term_spring_2025 },
  { student: student1, section: section_db_systems, term: term_spring_2025 },
  { student: student2, section: section_data_structure, term: term_spring_2025 },
  { student: student2, section: section_web_dev, term: term_spring_2025 },
  { student: student3, section: section_programming, term: term_spring_2025 },
  { student: student3, section: section_data_structure, term: term_spring_2025 }
]

enrollments.each do |enrollment_data|
  Enrollment.create!(
    student: enrollment_data[:student],
    section: enrollment_data[:section],
    academic_term: enrollment_data[:term],
    status: :active,
    registered_at: DateTime.now
  )
end

puts "Created #{Enrollment.count} enrollments"

# ============================================================
# ANNOUNCEMENTS
# ============================================================
puts "Creating announcements..."
Announcement.create!(
  user: admin_user,
  title: 'Spring 2025 Registration Open',
  content: 'Registration for Spring 2025 semester is now open. Please register for your courses before the deadline.',
  published_at: DateTime.now - 5.days,
  is_published: true
)

Announcement.create!(
  user: admin_user,
  title: 'New Library Hours',
  content: 'The university library will now be open from 8 AM to 10 PM Sunday through Thursday to support students during exam period.',
  published_at: DateTime.now - 2.days,
  is_published: true
)

puts "Created #{Announcement.count} announcements"

# ============================================================
# ATTENDANCE SESSIONS
# ============================================================
puts "Creating attendance sessions..."
AttendanceSession.create!(
  section: section_data_structure,
  date: Date.today,
  session_number: 1,
  status: :open
)

AttendanceSession.create!(
  section: section_db_systems,
  date: Date.today,
  session_number: 1,
  status: :open
)

puts "Created #{AttendanceSession.count} attendance sessions"

# ============================================================
# VERIFICATION SUMMARY
# ============================================================
puts "\n" + "="*60
puts "SEEDING COMPLETE"
puts "="*60
puts "Universities: #{University.count}"
puts "Faculties: #{Faculty.count}"
puts "Departments: #{Department.count}"
puts "Users: #{User.count}"
puts "Roles: #{Role.count}"
puts "Role Assignments: #{RoleUser.count}"
puts "Professors: #{Professor.count}"
puts "Students: #{Student.count}"
puts "Employees: #{Employee.count}"
puts "Courses: #{Course.count}"
puts "Department-Courses: #{DepartmentCourse.count}"
puts "Prerequisites: #{CoursePrerequisite.count}"
puts "Academic Terms: #{AcademicTerm.count}"
puts "Sections: #{Section.count}"
puts "Enrollments: #{Enrollment.count}"
puts "Announcements: #{Announcement.count}"
puts "Attendance Sessions: #{AttendanceSession.count}"
puts "="*60
puts "\nTest Users (password: password123):"
puts "  Admin: admin@unione.com"
puts "  Student: student@unione.com"
puts "  Professor: professor@unione.com"
puts "="*60
