# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_28_000012) do
  create_table "bike_positions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "recorded_at"
    t.integer "rider_id", null: false
    t.integer "session_id", null: false
    t.datetime "updated_at", null: false
    t.float "x"
    t.float "y"
    t.float "z"
    t.index ["rider_id"], name: "index_bike_positions_on_rider_id"
    t.index ["session_id", "rider_id"], name: "index_bike_positions_on_session_id_and_rider_id", unique: true
    t.index ["session_id"], name: "index_bike_positions_on_session_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "api_uuid"
    t.datetime "created_at", null: false
    t.integer "legacy_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["api_uuid"], name: "index_categories_on_api_uuid", unique: true
  end

  create_table "circuits", force: :cascade do |t|
    t.string "api_uuid"
    t.string "country"
    t.string "country_iso"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "short_name"
    t.text "svg_data"
    t.text "track_coordinates_json"
    t.datetime "updated_at", null: false
    t.index ["api_uuid"], name: "index_circuits_on_api_uuid", unique: true
  end

  create_table "constructors", force: :cascade do |t|
    t.string "api_uuid"
    t.string "colour"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["api_uuid"], name: "index_constructors_on_api_uuid", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "api_uuid"
    t.integer "circuit_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date"
    t.boolean "finished", default: false
    t.string "name"
    t.string "official_name"
    t.integer "season_id", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["api_uuid"], name: "index_events_on_api_uuid", unique: true
    t.index ["circuit_id"], name: "index_events_on_circuit_id"
    t.index ["season_id"], name: "index_events_on_season_id"
  end

  create_table "race_direction_messages", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "flag"
    t.integer "lap_number"
    t.text "message"
    t.datetime "recorded_at"
    t.integer "rider_number"
    t.string "scope"
    t.integer "sector"
    t.integer "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "recorded_at"], name: "index_race_direction_messages_on_session_id_and_recorded_at"
    t.index ["session_id"], name: "index_race_direction_messages_on_session_id"
  end

  create_table "riders", force: :cascade do |t|
    t.string "api_uuid"
    t.string "country_iso"
    t.datetime "created_at", null: false
    t.string "full_name"
    t.string "headshot_url"
    t.integer "legacy_id"
    t.string "name_acronym"
    t.integer "number"
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_riders_on_team_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "api_uuid"
    t.datetime "created_at", null: false
    t.boolean "current", default: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["year"], name: "index_seasons_on_year", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.float "air_temperature"
    t.string "api_uuid"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.integer "event_id", null: false
    t.float "humidity"
    t.string "session_type"
    t.datetime "start_date"
    t.string "status"
    t.float "track_temperature"
    t.datetime "updated_at", null: false
    t.string "weather_condition"
    t.index ["api_uuid"], name: "index_sessions_on_api_uuid", unique: true
    t.index ["category_id"], name: "index_sessions_on_category_id"
    t.index ["event_id"], name: "index_sessions_on_event_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "api_uuid"
    t.string "colour"
    t.integer "constructor_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["constructor_id"], name: "index_teams_on_constructor_id"
  end

  create_table "timing_entries", force: :cascade do |t|
    t.integer "best_lap_number"
    t.string "best_lap_time"
    t.datetime "created_at", null: false
    t.string "gap_to_leader"
    t.string "interval"
    t.string "last_lap_time"
    t.integer "pit_stop_count"
    t.integer "position"
    t.integer "rider_id", null: false
    t.boolean "sector_1_pb"
    t.boolean "sector_1_sb"
    t.string "sector_1_time"
    t.boolean "sector_2_pb"
    t.boolean "sector_2_sb"
    t.string "sector_2_time"
    t.boolean "sector_3_pb"
    t.boolean "sector_3_sb"
    t.string "sector_3_time"
    t.integer "session_id", null: false
    t.float "speed_trap"
    t.string "status"
    t.integer "tire_age"
    t.string "tire_compound"
    t.float "top_speed"
    t.integer "total_laps"
    t.datetime "updated_at", null: false
    t.index ["rider_id"], name: "index_timing_entries_on_rider_id"
    t.index ["session_id", "rider_id"], name: "index_timing_entries_on_session_id_and_rider_id", unique: true
    t.index ["session_id"], name: "index_timing_entries_on_session_id"
  end

  create_table "weather_snapshots", force: :cascade do |t|
    t.float "air_temperature"
    t.datetime "created_at", null: false
    t.float "humidity"
    t.float "pressure"
    t.integer "rainfall"
    t.datetime "recorded_at"
    t.integer "session_id", null: false
    t.float "track_temperature"
    t.datetime "updated_at", null: false
    t.integer "wind_direction"
    t.float "wind_speed"
    t.index ["session_id", "recorded_at"], name: "index_weather_snapshots_on_session_id_and_recorded_at"
    t.index ["session_id"], name: "index_weather_snapshots_on_session_id"
  end

  add_foreign_key "bike_positions", "riders"
  add_foreign_key "bike_positions", "sessions"
  add_foreign_key "events", "circuits"
  add_foreign_key "events", "seasons"
  add_foreign_key "race_direction_messages", "sessions"
  add_foreign_key "riders", "teams"
  add_foreign_key "sessions", "categories"
  add_foreign_key "sessions", "events"
  add_foreign_key "teams", "constructors"
  add_foreign_key "timing_entries", "riders"
  add_foreign_key "timing_entries", "sessions"
  add_foreign_key "weather_snapshots", "sessions"
end
