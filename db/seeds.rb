# frozen_string_literal: true

year = Time.current.year
Rails.logger.debug { "Seeding MotoGP data for #{year}..." }

begin
  season = Sync::SeasonsSync.new.call(year: year)
  categories = Sync::CategoriesSync.new.call(season: season)
  motogp = categories.find { |c| c.name == 'MotoGP' }

  Sync::EventsSync.new.call(season: season)

  if motogp
    season.events.find_each do |event|
      Sync::SessionsSync.new.call(event: event, category: motogp)
    end

    latest_event = season.events.order(start_date: :desc).first
    Sync::RidersSync.new.call(event: latest_event, category: motogp) if latest_event
  end

  Rails.logger.debug { "Seeded: #{Event.count} events, #{Session.count} sessions, #{Rider.count} riders" }
rescue MotoGpClient::ApiError => e
  Rails.logger.debug { "Warning: Could not seed from API (#{e.message}). Skipping live data sync." }
end
