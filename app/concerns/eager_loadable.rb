module EagerLoadable
  extend ActiveSupport::Concern

  class_methods do
    # Load common associations to prevent N+1 queries
    def with_common_associations
      includes(:user)
    end

    # Load student profile with associations
    def with_student_profile
      includes(student: [:user, :faculty, :department])
    end

    # Load professor profile with associations
    def with_professor_profile
      includes(professor: [:user, :department])
    end

    # Load enrollments with all necessary associations
    def with_enrollment_details
      includes(enrollments: [
        { section: [:course, :professor, :academic_term] },
        :academic_term,
        :grade
      ])
    end

    # Load sections with full details
    def with_section_details
      includes(sections: [
        :course,
        { professor: :user },
        :academic_term,
        { enrollments: [:student, :grade] }
      ])
    end
  end
end
