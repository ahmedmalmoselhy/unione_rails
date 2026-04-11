# UniOne Rails - Features Reference

This file aligns Rails scope with the canonical feature list in `UniOne/Features.md`.

## Canonical Features (Apply To All Versions)

1. Employees upload students lists via Excel sheets
2. Professors upload students grades via Excel sheets
3. Create/Modify Students
4. Create/Modify Professors
5. Create/Modify lectures schedule
6. Assign professor to course
7. Assign teaching assistant to course
8. Create/Manage group projects
9. Manage courses and lectures
10. Manage Employees
11. Publish announcements
12. Send announcements via email
13. Publish exams schedule
14. Send exams schedule via email
15. Publish final grades
16. Send final grades via email
17. Group students based on University, Faculty, Department and Course

## Rails Mapping Notes

- This list is the product requirement baseline.
- Implementation depth can vary by phase; use `CURRENT_STATUS.md` to track what is fully completed in Rails.
- New features should be added to the canonical list first, then mapped here.

## Feature Implementation in Rails

### 1. Excel Import/Export

**Employees upload students lists via Excel sheets**
- Gem: `roo` or `axlsx` for Excel parsing
- Admin endpoint: `POST /api/admin/imports/students`
- Template endpoint: `GET /api/admin/import-templates/students`
- Validation: ActiveModel validations on import
- Background job: `ImportStudentsJob`

**Professors upload students grades via Excel sheets**
- Professor endpoint: `POST /api/professor/sections/{id}/grades/import`
- Same Excel parsing gems
- Validation against enrolled students
- Bulk grade creation

### 2. CRUD Operations

**Create/Modify Students**
- Admin CRUD: `GET/POST/PATCH/DELETE /api/admin/students`
- Transfer: `POST /api/admin/students/{id}/transfer`
- Model: `Student` with validations
- Policy: `StudentPolicy`

**Create/Modify Professors**
- Admin CRUD: `GET/POST/PATCH/DELETE /api/admin/professors`
- Model: `Professor` with validations
- Policy: `ProfessorPolicy`

**Create/Modify lectures schedule**
- Section schedule: JSONB field
- Admin endpoint: `PATCH /api/admin/sections/{id}`
- Professor view: `GET /api/professor/schedule`

**Manage courses and lectures**
- Admin CRUD: `GET/POST/PATCH/DELETE /api/admin/courses`
- Section CRUD: `GET/POST/PATCH/DELETE /api/admin/sections`

**Manage Employees**
- Admin CRUD: `GET/POST/PATCH/DELETE /api/admin/employees`

### 3. Assignments

**Assign professor to course**
- Section creation: `professor_id` field
- Admin endpoint: `POST /api/admin/sections`

**Assign teaching assistant to course**
- TA assignment: `POST /api/admin/sections/{id}/teaching-assistants`
- Remove TA: `DELETE /api/admin/sections/{id}/teaching-assistants/{taId}`

### 4. Group Projects

**Create/Manage group projects**
- Future feature: GroupProject model
- Endpoints: `GET/POST/PATCH/DELETE /api/admin/group-projects`
- Associations: students, courses, deadlines

### 5. Communication

**Publish announcements**
- University-wide: `POST /api/announcements`
- Section-specific: `POST /api/professor/sections/{id}/announcements`
- Model: `Announcement`, `SectionAnnouncement`

**Send announcements via email**
- Mailer: `AnnouncementMailer`
- Background job: `SendAnnouncementEmailJob`
- Triggered on publish

**Publish exams schedule**
- Admin endpoint: `POST /api/admin/sections/{id}/exam-schedule`
- Publish: `POST /api/admin/sections/{id}/exam-schedule/publish`

**Send exams schedule via email**
- Mailer: `ExamScheduleMailer`
- Triggered on publish

**Publish final grades**
- Professor submits: `POST /api/professor/sections/{id}/grades`
- Admin publishes after approval
- Mailer: `GradeMailer`

**Send final grades via email**
- Mailer: `GradeMailer.final_grades`
- Background job for bulk sending

### 6. Organization

**Group students based on University, Faculty, Department and Course**
- Student model: `university_id`, `faculty_id`, `department_id`
- Enrollment: links students to courses via sections
- Scopes: hierarchical filtering
- Policies: scoped authorization

## Cross-Version Applicability Matrix

| Feature | Laravel | Node | Django | Rails |
| --- | --- | --- | --- | --- |
| Employees upload students lists via Excel sheets | Applicable | Applicable | Applicable | Applicable |
| Professors upload students grades via Excel sheets | Applicable | Applicable | Applicable | Applicable |
| Create/Modify Students | Applicable | Applicable | Applicable | Applicable |
| Create/Modify Professors | Applicable | Applicable | Applicable | Applicable |
| Create/Modify lectures schedule | Applicable | Applicable | Applicable | Applicable |
| Assign professor to course | Applicable | Applicable | Applicable | Applicable |
| Assign teaching assistant to course | Applicable | Applicable | Applicable | Applicable |
| Create/Manage group projects | Applicable | Applicable | Applicable | Applicable |
| Manage courses and lectures | Applicable | Applicable | Applicable | Applicable |
| Manage Employees | Applicable | Applicable | Applicable | Applicable |
| Publish announcements | Applicable | Applicable | Applicable | Applicable |
| Send announcements via email | Applicable | Applicable | Applicable | Applicable |
| Publish exams schedule | Applicable | Applicable | Applicable | Applicable |
| Send exams schedule via email | Applicable | Applicable | Applicable | Applicable |
| Publish final grades | Applicable | Applicable | Applicable | Applicable |
| Send final grades via email | Applicable | Applicable | Applicable | Applicable |
| Group students based on University, Faculty, Department and Course | Applicable | Applicable | Applicable | Applicable |

## Rails-Specific Implementation Details

### Gems for Features

```ruby
# Excel import/export
gem 'roo'                    # Read Excel files
gem 'axlsx'                  # Generate Excel files
gem 'axlsx_rails'            # Rails integration

# PDF generation
gem 'wicked_pdf'             # PDF from HTML
gem 'wkhtmltopdf-binary'     # wkhtmltopdf binary

# iCal export
gem 'icalendar'              # Generate .ics files

# Email
# Built-in: ActionMailer

# Background jobs
gem 'sidekiq'                # Or use GoodJob
gem 'redis'                  # For Sidekiq

# Authorization
gem 'pundit'                 # Policy-based auth

# Rate limiting
gem 'rack-attack'            # Rate limiting middleware

# File uploads
# Built-in: Active Storage
```

### Service Objects for Complex Features

```ruby
# app/services/student_import_service.rb
class StudentImportService
  def initialize(file_path)
    @file_path = file_path
  end

  def call
    workbook = Roo::Spreadsheet.open(@file_path)
    workbook.each_with_index do |row, index|
      next if index == 0 # Skip header
      
      Student.create!(
        student_number: row[0],
        first_name: row[1],
        last_name: row[2],
        email: row[3],
        faculty_id: row[4],
        department_id: row[5]
      )
    end
  end
end

# app/services/grade_submission_service.rb
class GradeSubmissionService
  def initialize(section, grades_data)
    @section = section
    @grades_data = grades_data
  end

  def call
    ActiveRecord::Base.transaction do
      @grades_data.each do |grade_entry|
        enrollment = @section.enrollments.find_by!(id: grade_entry[:enrollment_id])
        Grade.create!(
          enrollment: enrollment,
          points: grade_entry[:points],
          letter_grade: calculate_letter_grade(grade_entry[:points])
        )
      end
    end
  end

  private

  def calculate_letter_grade(points)
    case points
    when 90..100 then 'A'
    when 80..89 then 'B'
    when 70..79 then 'C'
    when 60..69 then 'D'
    else 'F'
    end
  end
end
```

### Background Jobs

```ruby
# app/jobs/send_announcement_email_job.rb
class SendAnnouncementEmailJob < ApplicationJob
  queue_as :mailers
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(announcement_id, user_id)
    announcement = Announcement.find(announcement_id)
    user = User.find(user_id)
    
    AnnouncementMailer.new_announcement(user, announcement).deliver_later
  end
end

# app/jobs/send_grade_notification_job.rb
class SendGradeNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    GradeMailer.grade_posted(enrollment).deliver_later
  end
end
```

### Mailers

```ruby
# app/mailers/announcement_mailer.rb
class AnnouncementMailer < ApplicationMailer
  def new_announcement(user, announcement)
    @user = user
    @announcement = announcement
    
    mail(
      to: @user.email,
      subject: "New Announcement: #{@announcement.title}"
    )
  end
end

# app/mailers/grade_mailer.rb
class GradeMailer < ApplicationMailer
  def grade_posted(enrollment)
    @enrollment = enrollment
    @student = enrollment.student
    @grade = enrollment.grade
    
    mail(
      to: @student.user.email,
      subject: "Your grade for #{@enrollment.section.course.name}"
    )
  end

  def final_grades_published(student)
    @student = student
    @grades = student.enrollments.includes(:grade, :section)
    
    mail(
      to: student.user.email,
      subject: "Final Grades Published"
    )
  end
end
```

## Feature Completion Checklist

- [ ] Excel import for students
- [ ] Excel import for grades
- [ ] Student CRUD (admin)
- [ ] Professor CRUD (admin)
- [ ] Employee CRUD (admin)
- [ ] Course CRUD (admin)
- [ ] Section CRUD (admin)
- [ ] Lecture schedule management
- [ ] Professor assignment to sections
- [ ] TA assignment to sections
- [ ] Group projects management
- [ ] Announcement publishing
- [ ] Announcement email notifications
- [ ] Exam schedule publishing
- [ ] Exam schedule email notifications
- [ ] Final grades publishing
- [ ] Final grades email notifications
- [ ] Student grouping by organization hierarchy

---

**Last Updated**: April 11, 2026
**Maintainers**: Development Team
**Status**: 🟢 Ready for Implementation
