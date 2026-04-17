module Mutations
  class EnrollInSection < BaseMutation
    argument :section_id, ID, required: true
    argument :student_id, ID, required: false # Optional, defaults to current user's student record

    field :enrollment, Types::SectionType, null: true # Or a new EnrollmentType
    field :errors, [String], null: false

    def resolve(section_id:, student_id: nil)
      user = require_authenticated_user!

      # Determine which student to enroll
      student = if student_id
                  # If student_id provided, check if user is admin
                  unless user.admin?
                    return { enrollment: nil, errors: ["Admin access required to enroll other students"] }
                  end
                  Student.find_by(id: student_id)
                else
                  # Default to current user's student record
                  user.student
                end

      unless student
        return { enrollment: nil, errors: ["Student record not found"] }
      end

      section = Section.find_by(id: section_id)
      unless section
        return { enrollment: nil, errors: ["Section not found"] }
      end

      # Check if already enrolled
      if Enrollment.exists?(student: student, section: section)
        return { enrollment: nil, errors: ["Already enrolled in this section"] }
      end

      # Check capacity
      if section.enrollments.count >= section.capacity
        return { enrollment: nil, errors: ["Section is full"] }
      end

      enrollment = Enrollment.new(
        student: student,
        section: section,
        academic_term: section.academic_term,
        registered_at: Time.current,
        status: :active
      )

      if enrollment.save
        # Note: In a real app, you might want to return the Enrollment object
        # but here I'll return the section to see the updated enrollment count if needed
        # or we could define a proper EnrollmentType
        { enrollment: section, errors: [] }
      else
        { enrollment: nil, errors: enrollment.errors.full_messages }
      end
    end
  end
end
