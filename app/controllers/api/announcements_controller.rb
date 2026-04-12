module Api
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [:show, :mark_read]

    def index
      @announcements = Announcement.where(is_published: true)
                                   .order(published_at: :desc)
                                   .page(params[:page])
                                   .per(params[:per_page] || 20)
      authorize Announcement

      render json: @announcements, include: ['user'], status: :ok
    end

    def show
      authorize @announcement

      render json: @announcement, include: ['user'], status: :ok
    end

    def mark_read
      authorize @announcement

      AnnouncementRead.find_or_create_by!(
        user: current_user,
        announcement: @announcement
      ) do |read|
        read.read_at = DateTime.current
      end

      render json: { message: 'Announcement marked as read' }, status: :ok
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end
  end
end
