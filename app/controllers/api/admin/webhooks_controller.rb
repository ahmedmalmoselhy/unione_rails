module Api
  module Admin
    class WebhooksController < BaseController
      before_action :set_webhook, only: [:show, :update, :destroy, :deliveries]

      def index
        @webhooks = current_user.webhooks.order(created_at: :desc)
        authorize Webhook

        render json: @webhooks, status: :ok
      end

      def show
        authorize @webhook

        render json: @webhook, include: ['webhook_deliveries'], status: :ok
      end

      def create
        @webhook = current_user.webhooks.new(webhook_params)
        authorize @webhook

        if @webhook.save
          render json: @webhook, status: :created
        else
          render json: { errors: @webhook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @webhook

        if @webhook.update(webhook_params)
          render json: @webhook, status: :ok
        else
          render json: { errors: @webhook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @webhook

        @webhook.destroy
        render json: { message: 'Webhook deleted' }, status: :ok
      end

      def deliveries
        authorize @webhook

        @deliveries = @webhook.webhook_deliveries.order(created_at: :desc)
                                                 .page(params[:page])
                                                 .per(params[:per_page] || 20)

        render json: @deliveries, status: :ok
      end

      private

      def set_webhook
        @webhook = current_user.webhooks.find(params[:id])
      end

      def webhook_params
        params.require(:webhook).permit(:url, :secret, events: [], :is_active)
      end
    end
  end
end
