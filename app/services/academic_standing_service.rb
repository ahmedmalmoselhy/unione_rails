class AcademicStandingService
  # Academic standing thresholds
  THRESHOLDS = {
    excellent: 3.7,
    good: 3.0,
    probation: 2.0,
    suspension: 0.0
  }.freeze

  def initialize(student)
    @student = student
  end

  # Calculate and update academic standing based on current GPA
  def update_standing
    gpa = GpaCalculator.new(@student).calculate_cumulative_gpa
    new_standing = determine_standing(gpa)

    if @student.academic_standing != new_standing
      @student.update(academic_standing: new_standing)
      {
        updated: true,
        old_standing: @student.academic_standing_before_last_save,
        new_standing: new_standing,
        gpa: gpa
      }
    else
      {
        updated: false,
        standing: new_standing,
        gpa: gpa
      }
    end
  end

  # Determine standing based on GPA
  def determine_standing(gpa)
    case gpa
    when THRESHOLDS[:excellent]..4.0 then 'excellent'
    when THRESHOLDS[:good]...THRESHOLDS[:excellent] then 'good'
    when THRESHOLDS[:probation]...THRESHOLDS[:good] then 'probation'
    else 'suspension'
    end
  end

  # Get standing description
  def standing_description(standing)
    descriptions = {
      excellent: 'Excellent - Dean\'s List eligible',
      good: 'Good - Satisfactory progress',
      probation: 'Probation - Academic warning, improvement required',
      suspension: 'Suspension - Not meeting minimum requirements'
    }
    descriptions[standing.to_sym] || 'Unknown standing'
  end

  # Check if student is eligible for Dean's List
  def deans_list_eligible?
    GpaCalculator.new(@student).calculate_cumulative_gpa >= THRESHOLDS[:excellent] &&
      GpaCalculator.new(@student).credit_hours_completed >= 12
  end

  # Check if student should be suspended
  def suspension_risk?
    GpaCalculator.new(@student).calculate_cumulative_gpa < THRESHOLDS[:probation]
  end

  # Get academic recommendations
  def recommendations
    gpa = GpaCalculator.new(@student).calculate_cumulative_gpa
    standing = determine_standing(gpa)
    recommendations = []

    case standing
    when 'excellent'
      recommendations << 'Consider applying for Dean\'s List recognition'
      recommendations << 'Eligible for honors programs'
      recommendations << 'Consider research opportunities'
    when 'good'
      recommendations << 'Maintain current academic performance'
      recommendations << 'Consider seeking academic enrichment opportunities'
    when 'probation'
      recommendations << 'Meet with academic advisor immediately'
      recommendations << 'Consider reducing course load'
      recommendations << 'Utilize tutoring and academic support services'
    when 'suspension'
      recommendations << 'Contact academic advisor to discuss options'
      recommendations << 'Review academic probation policies'
      recommendations << 'Consider academic leave and return plan'
    end

    recommendations
  end
end
