module Api
  class HealthController < ActionController::API
    def show
      checks = {
        database: database_check,
        redis: redis_check,
        sidekiq: sidekiq_check
      }

      overall_ok = checks.values.all? { |result| result[:ok] || result[:status] == 'skipped' }

      render json: {
        status: overall_ok ? 'ok' : 'degraded',
        timestamp: Time.current.utc.iso8601,
        checks: checks
      }, status: overall_ok ? :ok : :service_unavailable
    end

    private

    def database_check
      ActiveRecord::Base.connection.execute('SELECT 1')
      { ok: true }
    rescue StandardError => e
      { ok: false, error: e.message }
    end

    def redis_check
      return { ok: true, status: 'skipped', reason: 'REDIS_URL not configured' } unless ENV['REDIS_URL'].present?

      redis = Redis.new(url: ENV['REDIS_URL'])
      pong = redis.ping
      { ok: pong == 'PONG' }
    rescue StandardError => e
      { ok: false, error: e.message }
    end

    def sidekiq_check
      return { ok: true, status: 'skipped', reason: 'Sidekiq not loaded' } unless defined?(Sidekiq)

      process_count = Sidekiq::ProcessSet.new.size
      { ok: true, process_count: process_count }
    rescue StandardError => e
      { ok: false, error: e.message }
    end
  end
end
