module Api
  module Student
    class GradesController < BaseController
      def index
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :grades?

        @grades = Grade.joins(enrollment: [:section, :academic_term])
                       .where(enrollments: { student_id: @student.id })
                       .includes(enrollment: { section: :course })
                       .order('academic_terms.start_date DESC')

        render json: {
          success: true,
          data: {
            grades: @grades.map { |grade| grade_json(grade) },
            cumulative_gpa: GpaCalculator.new(@student).calculate_cumulative_gpa,
            credit_hours_completed: GpaCalculator.new(@student).credit_hours_completed
          }
        }, status: :ok
      end

      def by_term
        @student = current_user.student
        term = AcademicTerm.find(params[:term_id])

        authorize @student, :grades?

        @grades = Grade.joins(enrollment: [:section, :academic_term])
                       .where(enrollments: { student_id: @student.id, academic_term_id: term.id })
                       .includes(enrollment: { section: :course })

        term_gpa = StudentTermGpa.find_by(student: @student, academic_term: term)&.gpa || 0.0

        render json: {
          success: true,
          data: {
            term: {
              id: term.id,
              name: term.name,
              gpa: term_gpa
            },
            grades: @grades.map { |grade| grade_json(grade) }
          }
        }, status: :ok
      end

      private

      def grade_json(grade)
        {
          id: grade.id,
          course: {
            code: grade.enrollment.section.course.code,
            name: grade.enrollment.section.course.name,
            credit_hours: grade.enrollment.section.course.credit_hours
          },
          term: grade.enrollment.academic_term.name,
          points: grade.points,
          letter_grade: grade.letter_grade,
          status: grade.status,
          created_at: grade.created_at,
          updated_at: grade.updated_at
        }
      end
    end
  end
end
