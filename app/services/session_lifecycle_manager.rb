# frozen_string_literal: true

require 'concurrent'

class SessionLifecycleManager
  CHECK_INTERVAL = 60
  LOG_TAG = '[SessionLifecycleManager]'

  def initialize(client: MotoGpClient.new)
    @client = client
    @pollers = {}
    @mutex = Mutex.new
    @task = nil
  end

  def start
    Rails.logger.info "#{LOG_TAG} Starting lifecycle manager"
    check_sessions

    @task = Concurrent::TimerTask.new(execution_interval: CHECK_INTERVAL) do
      check_sessions
    end
    @task.execute
  end

  def stop
    Rails.logger.info "#{LOG_TAG} Stopping lifecycle manager"
    @task&.shutdown

    @mutex.synchronize do
      @pollers.each_value(&:stop)
      @pollers.clear
    end
  end

  def active_pollers
    @mutex.synchronize { @pollers.dup }
  end

  private

  def check_sessions
    sync_session_statuses
    manage_pollers
  rescue StandardError => e
    Rails.logger.error "#{LOG_TAG} Error checking sessions: #{e.message}"
  end

  def sync_session_statuses
    live_sessions = Session.live
    return if live_sessions.any?

    recent_events = Event.order(start_date: :desc).limit(3)
    motogp = Category.find_by(name: 'MotoGP')
    return unless motogp

    recent_events.each do |event|
      Sync::SessionsSync.new(client: @client).call(event: event, category: motogp)
    end
  rescue MotoGpClient::ApiError => e
    Rails.logger.warn "#{LOG_TAG} API error syncing session statuses: #{e.message}"
  end

  def manage_pollers
    live_sessions = Session.live.to_a
    live_ids = live_sessions.to_set(&:id)

    @mutex.synchronize do
      @pollers.each do |session_id, poller|
        next if live_ids.include?(session_id)

        Rails.logger.info "#{LOG_TAG} Session #{session_id} no longer live, stopping poller"
        poller.stop
        @pollers.delete(session_id)
      end

      live_sessions.each do |session|
        next if @pollers.key?(session.id)

        Rails.logger.info "#{LOG_TAG} Session #{session.id} is live, starting poller"
        poller = LiveSessionPoller.new(session, client: @client)
        poller.start
        @pollers[session.id] = poller
      end
    end
  end
end
