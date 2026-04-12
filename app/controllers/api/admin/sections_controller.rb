module Api
  module Admin
    class SectionsController < BaseController
      before_action :set_section, only: [:show, :update, :destroy]

      def index
        authorize ::Section

        @sections = ::Section.includes(:course, :professor, :academic_term)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(params[:per_page] || 20)

        # Filters
        if params[:course_id]
          @sections = @sections.where(course_id: params[:course_id])
        end

        if params[:professor_id]
          @sections = @sections.where(professor_id: params[:professor_id])
        end

        if params[:academic_term_id]
          @sections = @sections.where(academic_term_id: params[:academic_term_id])
        end

        render json: {
          success: true,
          data: {
            sections: @sections.map { |s| section_json(s) },
            total: @sections.total_count,
            page: @sections.current_page
          }
        }, status: :ok
      end

      def show
        authorize @section

        render json: {
          success: true,
          data: {
            section: section_json(@section, include_details: true)
          }
        }, status: :ok
      end

      def create
        @section = ::Section.new(section_params)
        authorize @section

        if @section.save
          render json: {
            success: true,
            message: 'Section created successfully',
            data: {
              section: section_json(@section)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @section.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @section

        if @section.update(section_params)
          render json: {
            success: true,
            data: {
              section: section_json(@section)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @section.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @section

        if @section.enrollments.any?
          return render json: {
            success: false,
            error: 'Cannot delete section with existing enrollments'
          }, status: :unprocessable_entity
        end

        @section.destroy
        
        render json: {
          success: true,
          message: 'Section deleted'
        }, status: :ok
      end

      def statistics
        authorize ::Section

        stats = {
          total_sections: ::Section.count,
          sections_by_term: ::AcademicTerm.joins(:sections)
                                          .group('academic_terms.name')
                                          .count('sections.id'),
          sections_by_course: ::Course.joins(:sections)
                                     .group('courses.code')
                                     .count('sections.id'),
          average_capacity_utilization: calculate_capacity_utilization,
          total_enrollments: ::Enrollment.where(status: :active).count
        }

        render json: {
          success: true,
          data: stats
        }, status: :ok
      end

      private

      def set_section
        @section = ::Section.find(params[:id])
      end

      def section_json(section, include_details: false)
        json = {
          id: section.id,
          course: {
            id: section.course.id,
            code: section.course.code,
            name: section.course.name
          },
          professor: {
            id: section.professor.id,
            name: section.professor.user.full_name
          },
          academic_term: {
            id: section.academic_term.id,
            name: section.academic_term.name
          },
          semester: section.semester,
          capacity: section.capacity,
          enrolled_count: section.enrollments.active.count,
          schedule: section.schedule,
          created_at: section.created_at
        }

        if include_details
          json.merge!({
            updated_at: section.updated_at,
            enrollments: section.enrollments.includes(student: :user).map do |e|
              {
                id: e.id,
                student: e.student.user.full_name,
                student_number: e.student.student_number,
                status: e.status,
                registered_at: e.registered_at
              }
            end
          })
        end

        json
      end

      def section_params
        params.require(:section).permit(
          :course_id, :professor_id, :academic_term_id, :semester,
          :capacity, :schedule
        )
      end

      def calculate_capacity_utilization
        sections = ::Section.all
        return 0.0 if sections.empty?

        utilizations = sections.map do |section|
          (section.enrollments.active.count / section.capacity.to_f * 100)
        end

        (utilizations.sum / utilizations.size).round(2)
      end
    end
  end
end
