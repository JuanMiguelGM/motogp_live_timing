# frozen_string_literal: true

class SessionChannel < ApplicationCable::Channel
  def subscribed
    session = Session.find_by(id: params[:session_id])

    if session
      stream_for session
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
