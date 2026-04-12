module Api
  module Student
    class RatingsController < BaseController
      def index
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end

        authorize @student, :ratings?

        @ratings = CourseRating.joins(enrollment: [:section, :academic_term])
                               .where(enrollments: { student_id: @student.id })
                               .includes(enrollment: { section: :course })
                               .order(submitted_at: :desc)

        render json: {
          success: true,
          data: {
            ratings: @ratings.map { |rating| rating_json(rating) }
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

        enrollment = @student.enrollments.find_by(id: params[:enrollment_id])

        unless enrollment
          return render json: {
            success: false,
            error: 'Enrollment not found'
          }, status: :not_found
        end

        # Check if rating already exists
        if CourseRating.exists?(enrollment_id: enrollment.id)
          return render json: {
            success: false,
            error: 'Rating already submitted for this course'
          }, status: :unprocessable_entity
        end

        # Only allow rating submission for completed courses
        unless enrollment.completed?
          return render json: {
            success: false,
            error: 'Can only rate completed courses'
          }, status: :unprocessable_entity
        end

        @rating = CourseRating.new(
          enrollment: enrollment,
          rating: params[:rating],
          feedback: params[:feedback],
          submitted_at: DateTime.current
        )

        if @rating.save
          render json: {
            success: true,
            message: 'Rating submitted successfully',
            data: {
              rating: rating_json(@rating)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @rating.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def rating_json(rating)
        {
          id: rating.id,
          course: {
            code: rating.enrollment.section.course.code,
            name: rating.enrollment.section.course.name
          },
          term: rating.enrollment.academic_term.name,
          rating: rating.rating,
          feedback: rating.feedback,
          submitted_at: rating.submitted_at,
          created_at: rating.created_at
        }
      end
    end
  end
end
