module Api
  module Admin
    class AuditLogsController < BaseController
      def index
        authorize AuditLog

        @audit_logs = AuditLog.includes(:user)
                             .order(created_at: :desc)
                             .page(params[:page])
                             .per(params[:per_page] || 20)

        # Filters
        if params[:user_id]
          @audit_logs = @audit_logs.where(user_id: params[:user_id])
        end

        if params[:action_type]
          @audit_logs = @audit_logs.where(action: params[:action_type])
        end

        if params[:auditable_type]
          @audit_logs = @audit_logs.where(auditable_type: params[:auditable_type])
        end

        if params[:start_date]
          @audit_logs = @audit_logs.where('created_at >= ?', params[:start_date])
        end

        if params[:end_date]
          @audit_logs = @audit_logs.where('created_at <= ?', params[:end_date])
        end

        render json: {
          success: true,
          data: {
            audit_logs: @audit_logs.map { |log| log_json(log) },
            total: @audit_logs.total_count,
            page: @audit_logs.current_page
          }
        }, status: :ok
      end

      def show
        @audit_log = AuditLog.includes(:user).find(params[:id])
        authorize @audit_log

        render json: {
          success: true,
          data: {
            audit_log: log_json(@audit_log)
          }
        }, status: :ok
      end

      def statistics
        authorize AuditLog

        stats = {
          total_logs: AuditLog.count,
          by_action: AuditLog.group(:action).count,
          by_user: AuditLog.group(:user_id).count,
          recent_activity: AuditLog.where('created_at >= ?', 7.days.ago).count,
          top_auditable_types: AuditLog.group(:auditable_type).count.sort_by { |_, v| -v }.first(10).to_h
        }

        render json: {
          success: true,
          data: stats
        }, status: :ok
      end

      private

      def log_json(log)
        {
          id: log.id,
          user: log.user ? {
            id: log.user.id,
            name: log.user.full_name,
            email: log.user.email
          } : nil,
          action: log.action,
          auditable_type: log.auditable_type,
          auditable_id: log.auditable_id,
          description: log.description,
          old_values: log.old_values,
          new_values: log.new_values,
          ip_address: log.ip_address,
          created_at: log.created_at
        }
      end
    end
  end
end
