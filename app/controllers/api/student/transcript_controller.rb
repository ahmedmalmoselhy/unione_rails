module Api
  module Student
    class TranscriptController < BaseController
      def show
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :transcript?

        transcript = TranscriptGenerator.new(@student).generate

        render json: {
          success: true,
          data: transcript
        }, status: :ok
      end

      def academic_history
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :transcript?

        # Get all terms with enrollments
        @terms = AcademicTerm.joins(enrollments: :student)
                            .where(students: { id: @student.id })
                            .distinct
                            .order(start_date: :desc)

        history = @terms.map do |term|
          term_gpa = StudentTermGpa.find_by(student: @student, academic_term: term)
          
          {
            term: {
              id: term.id,
              name: term.name,
              start_date: term.start_date,
              end_date: term.end_date
            },
            gpa: term_gpa&.gpa,
            credit_hours: term_gpa&.credit_hours_completed || 0,
            courses: get_courses_for_term(term)
          }
        end

        render json: {
          success: true,
          data: {
            student: {
              student_number: @student.student_number,
              name: @student.user.full_name,
              faculty: @student.faculty.name,
              department: @student.department.name
            },
            cumulative_gpa: GpaCalculator.new(@student).calculate_cumulative_gpa,
            total_credit_hours: GpaCalculator.new(@student).credit_hours_completed,
            academic_standing: @student.academic_standing,
            terms: history
          }
        }, status: :ok
      end

      private

      def get_courses_for_term(term)
        enrollments = @student.enrollments
                              .where(academic_term_id: term.id)
                              .includes(section: :course)
                              .includes(:grade)

        enrollments.map do |enrollment|
          {
            code: enrollment.section.course.code,
            name: enrollment.section.course.name,
            credit_hours: enrollment.section.course.credit_hours,
            grade: enrollment.grade&.letter_grade || 'In Progress',
            points: enrollment.grade&.points
          }
        end
      end
    end
  end
end
