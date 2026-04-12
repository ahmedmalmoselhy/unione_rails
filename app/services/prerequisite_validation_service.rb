class PrerequisiteValidationService
  def initialize(student)
    @student = student
  end

  # Check if student has completed all prerequisites for a course
  def prerequisites_met?(course)
    course.prerequisites.all? { |prereq| prerequisite_completed?(prereq) }
  end

  # Get list of unmet prerequisites
  def unmet_prerequisites(course)
    course.prerequisites.reject { |prereq| prerequisite_completed?(prereq) }
  end

  # Check if a specific prerequisite has been completed
  def prerequisite_completed?(course)
    enrollment = @student.enrollments
                         .joins(section: :course)
                         .find_by(sections: { course_id: course.id })

    return false unless enrollment
    return false unless enrollment.grade

    # Must have passed the course (grade not F)
    enrollment.grade.letter_grade != 'F'
  end

  # Get all courses student is eligible for based on completed prerequisites
  def eligible_courses(department = nil)
    courses = department ? department.courses : Course.where(is_active: true)

    courses.select do |course|
      prerequisites_met?(course) && !already_enrolled_or_completed?(course)
    end
  end

  # Check if student is already enrolled in or has completed a course
  def already_enrolled_or_completed?(course)
    @student.enrollments.joins(section: :course).exists?(courses: { id: course.id })
  end

  # Get recommended courses based on completed courses and prerequisites
  def recommended_courses(level = nil)
    completed_courses = @student.enrollments
                                .joins(section: :course, :grade)
                                .where.not(grades: { letter_grade: 'F' })
                                .pluck('courses.id')

    # Get courses where all prerequisites are in completed_courses
    recommendations = Course.where(is_active: true)
    
    recommendations = recommendations.where(level: level) if level

    recommendations.select do |course|
      next false if already_enrolled_or_completed?(course)
      
      course.prerequisites.all? { |prereq| completed_courses.include?(prereq.id) }
    end
  end

  # Validate enrollment request against prerequisites
  def validate_enrollment(section)
    course = section.course
    errors = []

    unless prerequisites_met?(course)
      unmet = unmet_prerequisites(course)
      errors << "Prerequisites not met: #{unmet.map(&:code).join(', ')}"
    end

    if already_enrolled_or_completed?(course)
      errors << "Already enrolled in or completed #{course.code}"
    end

    errors
  end
end
