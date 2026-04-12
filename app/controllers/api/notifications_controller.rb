module Api
  class NotificationsController < BaseController
    before_action :set_notification, only: [:mark_read, :destroy]

    def index
      @notifications = current_user.notifications
                                   .order(created_at: :desc)
                                   .page(params[:page])
                                   .per(params[:per_page] || 20)

      if params[:unread] == 'true'
        @notifications = @notifications.where(read_at: nil)
      end

      render json: @notifications, status: :ok
    end

    def mark_read
      @notification.update(read_at: DateTime.current)

      render json: { message: 'Notification marked as read' }, status: :ok
    end

    def mark_all_read
      current_user.notifications.where(read_at: nil).update_all(read_at: DateTime.current)

      render json: { message: 'All notifications marked as read' }, status: :ok
    end

    def destroy
      @notification.destroy

      render json: { message: 'Notification deleted' }, status: :ok
    end

    private

    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end
  end
end
