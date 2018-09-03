module ForemanOpenscap
  module BodyLogExtensions
    extend ActiveSupport::Concern

    def log_response_body
      return super unless skip_body_log.include?(action_name)
      logger.debug { logger_msg }
    end

    def skip_body_log
      ['xml']
    end

    def logger_msg
      "Logging response body of #{response.body.length} characters skipped when downloading DS files"
    end
  end
end
