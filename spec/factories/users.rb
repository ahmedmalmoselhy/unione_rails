FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { 'John' }
    last_name { 'Doe' }
    password { 'password123' }
    is_active { true }

    trait :admin do
      after(:create) do |user|
        role = Role.find_by(slug: 'admin') || create(:role, :admin)
        user.roles << role
      end
    end

    trait :student do
      after(:create) do |user|
        role = Role.find_by(slug: 'student') || create(:role, :student)
        user.roles << role
      end
    end

    trait :professor do
      after(:create) do |user|
        role = Role.find_by(slug: 'professor') || create(:role, :professor)
        user.roles << role
      end
    end

    trait :inactive do
      is_active { false }
    end
  end

  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:slug) { |n| "role_#{n}" }

    trait :admin do
      name { 'Admin' }
      slug { 'admin' }
    end

    trait :student do
      name { 'Student' }
      slug { 'student' }
    end

    trait :professor do
      name { 'Professor' }
      slug { 'professor' }
    end
  end
end
