module Api
  module Student
    class WaitlistController < BaseController
      def index
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        @waitlists = EnrollmentWaitlist.where(student_id: @student.id)
                                       .includes(:section, :academic_term)
                                       .order(position: :asc)

        render json: {
          success: true,
          data: {
            waitlist_entries: @waitlists.map { |entry| waitlist_json(entry) }
          }
        }, status: :ok
      end

      def create
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        section = Section.find(params[:section_id])
        academic_term = AcademicTerm.find_by(id: params[:academic_term_id]) || AcademicTerm.find_by(is_active: true)

        unless academic_term
          return render json: {
            success: false,
            error: 'No active academic term found'
          }, status: :unprocessable_entity
        end

        # Check if already enrolled
        if @student.enrollments.exists?(section_id: section.id, academic_term_id: academic_term.id, status: :active)
          return render json: {
            success: false,
            error: 'Already enrolled in this section'
          }, status: :unprocessable_entity
        end

        # Check if already on waitlist
        if EnrollmentWaitlist.exists?(student_id: @student.id, section_id: section.id, academic_term_id: academic_term.id)
          return render json: {
            success: false,
            error: 'Already on waitlist for this section'
          }, status: :unprocessable_entity
        end

        # Calculate position (last in line)
        last_position = EnrollmentWaitlist.where(section_id: section.id, academic_term_id: academic_term.id)
                                          .maximum(:position) || 0

        # Calculate priority score based on GPA and academic year
        priority_score = calculate_priority_score(@student)

        waitlist_entry = EnrollmentWaitlist.create!(
          student: @student,
          section: section,
          academic_term: academic_term,
          position: last_position + 1,
          priority_score: priority_score,
          requested_at: DateTime.current
        )

        render json: {
          success: true,
          message: 'Added to waitlist',
          data: {
            waitlist_entry: waitlist_json(waitlist_entry)
          }
        }, status: :created
      end

      def destroy
        @student = current_user.student
        waitlist_entry = EnrollmentWaitlist.find_by(
          student_id: @student.id,
          section_id: params[:section_id]
        )

        unless waitlist_entry
          return render json: {
            success: false,
            error: 'Waitlist entry not found'
          }, status: :not_found
        end

        waitlist_entry.destroy

        render json: {
          success: true,
          message: 'Removed from waitlist'
        }, status: :ok
      end

      private

      def calculate_priority_score(student)
        # Priority based on GPA (higher GPA = higher priority)
        # and academic year (senior students get priority)
        gpa_score = student.gpa.to_f * 10 # Max 40 points
        year_score = student.academic_year * 5 # Max 20 points for year 4
        
        (gpa_score + year_score).round(2)
      end

      def waitlist_json(entry)
        {
          id: entry.id,
          section: {
            id: entry.section.id,
            course_code: entry.section.course.code,
            course_name: entry.section.course.name,
            professor: entry.section.professor.user.full_name
          },
          academic_term: {
            id: entry.academic_term.id,
            name: entry.academic_term.name
          },
          position: entry.position,
          priority_score: entry.priority_score,
          requested_at: entry.requested_at,
          created_at: entry.created_at
        }
      end
    end
  end
end
