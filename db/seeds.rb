# Seed roles
roles = [
  { name: 'Admin', slug: 'admin', description: 'Full system access' },
  { name: 'Faculty Admin', slug: 'faculty_admin', description: 'Faculty-level management' },
  { name: 'Department Admin', slug: 'department_admin', description: 'Department-level management' },
  { name: 'Professor', slug: 'professor', description: 'Course management and grading' },
  { name: 'Student', slug: 'student', description: 'Course enrollment and grades' },
  { name: 'Employee', slug: 'employee', description: 'Administrative tasks' }
]

roles.each do |role_attrs|
  Role.find_or_create_by(slug: role_attrs[:slug]) do |role|
    role.name = role_attrs[:name]
    role.description = role_attrs[:description]
  end
end

puts "Created #{roles.count} roles"

# Create test admin user
admin = User.find_or_create_by(email: 'admin@unione.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.password = 'password123'
  user.phone = '+1234567890'
end

admin_role = Role.find_by(slug: 'admin')
admin.roles << admin_role unless admin.roles.include?(admin_role)

puts "Created admin user: #{admin.email} (password: password123)"

# Create test student user
student = User.find_or_create_by(email: 'student@unione.com') do |user|
  user.first_name = 'John'
  user.last_name = 'Doe'
  user.password = 'password123'
  user.phone = '+1234567891'
end

student_role = Role.find_by(slug: 'student')
student.roles << student_role unless student.roles.include?(student_role)

puts "Created student user: #{student.email} (password: password123)"

# Create test professor user
professor = User.find_or_create_by(email: 'professor@unione.com') do |user|
  user.first_name = 'Jane'
  user.last_name = 'Smith'
  user.password = 'password123'
  user.phone = '+1234567892'
end

professor_role = Role.find_by(slug: 'professor')
professor.roles << professor_role unless professor.roles.include?(professor_role)

puts "Created professor user: #{professor.email} (password: password123)"
