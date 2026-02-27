# frozen_string_literal: true

Rails.application.config.after_initialize do
  if defined?(Rails::Server) && !Rails.env.test?
    Thread.new do
      sleep 5
      Rails.logger.info '[LivePoller] Initializing session lifecycle manager'
      manager = SessionLifecycleManager.new
      manager.start

      at_exit do
        Rails.logger.info '[LivePoller] Shutting down session lifecycle manager'
        manager.stop
      end
    end
  end
end
