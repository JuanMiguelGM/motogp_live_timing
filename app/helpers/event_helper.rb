# frozen_string_literal: true

module EventHelper
  def event_time_status(event)
    if event.sessions.live.any?
      :live
    elsif event.start_date && event.start_date > Time.current
      :upcoming
    else
      :past
    end
  end

  def event_winner(event)
    race_session = event.sessions.find { |s| s.session_type == 'RAC' && s.status == 'finished' }
    return nil unless race_session

    race_session.timing_entries.min_by { |e| e.position || Float::INFINITY }
  end
end
