# frozen_string_literal: true

namespace :motogp do
  desc 'Sync all events and sessions for a given year from MotoGP API'
  task :sync_season, [:year] => :environment do |_t, args|
    year = (args[:year] || Time.current.year).to_i
    puts "Syncing MotoGP season #{year}..."

    season = Sync::SeasonsSync.new.call(year: year)
    puts "  Season: #{season.year} (#{season.api_uuid})"

    categories = Sync::CategoriesSync.new.call(season: season)
    motogp = categories.find { |c| c.name == 'MotoGP' }
    puts "  Found #{categories.size} categories, using MotoGP: #{motogp&.api_uuid}"

    Sync::EventsSync.new.call(season: season)
    puts "  Synced #{season.events.count} events"

    if motogp
      season.events.find_each do |event|
        puts "  Syncing sessions for #{event.name}..."
        sessions = Sync::SessionsSync.new.call(event: event, category: motogp)
        puts "    #{sessions.size} sessions synced"
      end
    end

    puts "Done! Season #{year} synced."
  end

  desc 'Sync riders for a given event'
  task :sync_riders, [:event_uuid] => :environment do |_t, args|
    event = Event.find_by!(api_uuid: args[:event_uuid])
    motogp = Category.find_by(name: 'MotoGP')
    raise 'No MotoGP category found. Run sync_season first.' unless motogp

    puts "Syncing riders for #{event.name}..."
    Sync::RidersSync.new.call(event: event, category: motogp)
    puts "Done! #{Rider.count} riders in database."
  end

  desc 'Rebuild track map SVGs for all circuits from bundled seed data'
  task rebuild_tracks: :environment do
    puts "Rebuilding track maps for #{Circuit.count} circuits from seed data..."

    Circuit.update_all(track_coordinates_json: nil, svg_data: nil)

    TrackMapBuilder.rebuild_all_from_seed do |status, circuit, reason|
      case status
      when :ok
        puts "  [OK]   #{circuit.name}"
      when :skip
        puts "  [SKIP] #{circuit.name} — #{reason}"
      end
    end

    built = Circuit.where.not(svg_data: nil).count
    puts "Done! #{built}/#{Circuit.count} circuits rebuilt."
  end
end
