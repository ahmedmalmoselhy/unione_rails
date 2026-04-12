module Api
  module Professor
    class AnnouncementsController < BaseController
      before_action :set_professor
      before_action :set_section
      before_action :set_announcement, only: [:update, :destroy]

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
            announcements: @announcements.map { |announcement| announcement_json(announcement) }
          }
        }, status: :ok
      end

      def create
        authorize @section, :create_announcement?

        @announcement = @section.section_announcements.new(
          user: current_user,
          title: params[:title],
          content: params[:content],
          published_at: DateTime.current
        )

        if @announcement.save
          # Send notification to all students in the section
          @section.students.each do |student|
            NotificationBroadcastService.broadcast_to_user(
              student.user,
              notification_type: 'SectionAnnouncementNotification',
              data: {
                title: @announcement.title,
                message: @announcement.content,
                announcement_id: @announcement.id,
                section_id: @section.id,
                course_code: @section.course.code
              },
              notifiable_type: 'Student',
              notifiable_id: student.id
            )
          end

          render json: {
            success: true,
            message: 'Announcement created',
            data: {
              announcement: announcement_json(@announcement)
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: @announcement.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @announcement, :update?

        if @announcement.update(announcement_params)
          render json: {
            success: true,
            data: {
              announcement: announcement_json(@announcement)
            }
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @announcement.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @announcement, :destroy?

        @announcement.destroy

        render json: {
          success: true,
          message: 'Announcement deleted'
        }, status: :ok
      end

      private

      def set_professor
        @professor = current_user.professor
        
        unless @professor
          return render json: {
            success: false,
            error: 'User does not have a professor profile'
          }, status: :forbidden
        end
      end

      def set_section
        @section = @professor.sections.find(params[:section_id])
      end

      def set_announcement
        @announcement = @section.section_announcements.find(params[:id])
      end

      def announcement_params
        params.require(:announcement).permit(:title, :content)
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
