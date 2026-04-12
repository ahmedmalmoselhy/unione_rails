module Api
  module Student
    class SectionAnnouncementsController < BaseController
      before_action :set_student
      before_action :set_section
      before_action :set_announcement, only: [:show]

      def index
        authorize @section, :announcements?

        @announcements = @section.section_announcements
                                 .includes(:user)
                                 .order(published_at: :desc)

        render json: {
          success: true,
          data: {
            section: {
              id: @section.id,
              course_code: @section.course.code,
              course_name: @section.course.name
            },
            announcements: @announcements.map { |a| announcement_json(a) }
          }
        }, status: :ok
      end

      def show
        authorize @section, :announcements?

        render json: {
          success: true,
          data: {
            announcement: announcement_json(@announcement)
          }
        }, status: :ok
      end

      private

      def set_student
        @student = current_user.student
        
        unless @student
          return render json: {
            success: false,
            error: 'User does not have a student profile'
          }, status: :forbidden
        end
      end

      def set_section
        @section = @student.sections.find(params[:section_id])
      end

      def set_announcement
        @announcement = @section.section_announcements.find(params[:id])
      end

      def announcement_json(announcement)
        {
          id: announcement.id,
          title: announcement.title,
          content: announcement.content,
          published_at: announcement.published_at,
          author: announcement.user.full_name,
          created_at: announcement.created_at,
          updated_at: announcement.updated_at
        }
      end
    end
  end
end
