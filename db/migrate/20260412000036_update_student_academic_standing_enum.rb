class UpdateStudentAcademicStandingEnum < ActiveRecord::Migration[7.1]
  def up
    # Update existing data to match new enum
    Student.where(academic_standing: 0).update_all(academic_standing: 1) # good -> good
    Student.where(academic_standing: 1).update_all(academic_standing: 2) # probation -> probation  
    Student.where(academic_standing: 2).update_all(academic_standing: 3) # suspension -> suspension
    
    # Add 'excellent' as new value 0
    # The enum in the model now handles the mapping
  end

  def down
    Student.where(academic_standing: 0).update_all(academic_standing: 1) # excellent -> good
    Student.where(academic_standing: 3).update_all(academic_standing: 2) # suspension -> suspension
  end
end
