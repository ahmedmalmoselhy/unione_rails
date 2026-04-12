FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:slug) { |n| "role_#{n}" }
    description { "Test role" }
  end

  factory :user do
    sequence(:national_id) { |n| "NID#{n.to_s.rjust(10, '0')}" }
    sequence(:email) { |n| "user#{n}@test.com" }
    password { 'password123' }
    first_name { 'Test' }
    last_name { 'User' }
    phone { '+1234567890' }
    is_active { true }

    trait :admin do
      after(:create) do |user|
        role = Role.find_or_create_by(slug: 'admin')
        user.roles << role
      end
    end

    trait :student do
      after(:create) do |user|
        role = Role.find_or_create_by(slug: 'student')
        user.roles << role
      end
    end

    trait :professor do
      after(:create) do |user|
        role = Role.find_or_create_by(slug: 'professor')
        user.roles << role
      end
    end
  end

  factory :admin_user, parent: :user, traits: [:admin] do
    sequence(:email) { |n| "admin#{n}@test.com" }
  end

  factory :student_user, parent: :user, traits: [:student] do
    sequence(:email) { |n| "student#{n}@test.com" }
  end

  factory :professor_user, parent: :user, traits: [:professor] do
    sequence(:email) { |n| "professor#{n}@test.com" }
  end

  factory :university do
    name { 'Test University' }
    sequence(:code) { |n| "UNI#{n}" }
    country { 'Test Country' }
    city { 'Test City' }
  end

  factory :faculty do
    name { 'Test Faculty' }
    sequence(:code) { |n| "FAC#{n}" }
    association :university
  end

  factory :department do
    name { 'Test Department' }
    sequence(:code) { |n| "DEP#{n}" }
    association :faculty
  end

  factory :student do
    sequence(:student_number) { |n| "STU#{n.to_s.rjust(6, '0')}" }
    academic_year { 1 }
    semester { 1 }
    enrollment_status { :active }
    gpa { 3.5 }
    academic_standing { :good }
    enrolled_at { Date.current - 1.year }
    association :user, factory: :student_user
    association :faculty
    association :department
  end

  factory :professor do
    sequence(:staff_number) { |n| "PROF#{n.to_s.rjust(4, '0')}" }
    specialization { 'Test Specialization' }
    academic_rank { 'Assistant Professor' }
    hired_at { Date.current - 5.years }
    association :user, factory: :professor_user
    association :department
  end

  factory :course do
    sequence(:code) { |n| "CS#{100 + n}" }
    name { 'Test Course' }
    credit_hours { 3 }
    lecture_hours { 3 }
    lab_hours { 0 }
    level { 100 }
    is_active { true }
  end

  factory :academic_term do
    name { 'Fall 2025' }
    start_date { Date.current - 3.months }
    end_date { Date.current + 3.months }
    registration_start { Date.current - 4.months }
    registration_end { Date.current - 2.months }
    is_active { true }
  end

  factory :section do
    sequence(:semester) { |n| n }
    capacity { 40 }
    schedule { { days: [1, 3, 5], start_time: '09:00', end_time: '10:30', location: 'Room 101' } }
    association :course
    association :professor
    association :academic_term
  end

  factory :enrollment do
    status { :active }
    registered_at { DateTime.current }
    association :student
    association :section
    association :academic_term
  end

  factory :announcement do
    title { 'Test Announcement' }
    content { 'This is a test announcement.' }
    published_at { DateTime.current }
    is_published { true }
    association :user
  end
end
