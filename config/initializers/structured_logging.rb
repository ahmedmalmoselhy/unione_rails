require 'json'
require 'time'

if Rails.env.production? && ENV.fetch('LOG_FORMAT', 'json') == 'json'
  class JsonLogFormatter < ::Logger::Formatter
    def call(severity, time, progname, msg)
      payload = {
        severity: severity,
        time: time.utc.iso8601(3),
        progname: progname,
        message: msg2str(msg)
      }

      "#{payload.to_json}\n"
    end
  end

  Rails.application.config.log_formatter = JsonLogFormatter.new
end
