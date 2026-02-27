# frozen_string_literal: true

class CreateWeatherSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :weather_snapshots do |t|
      t.references :session, null: false, foreign_key: true
      t.float :air_temperature
      t.float :track_temperature
      t.float :humidity
      t.float :pressure
      t.float :wind_speed
      t.integer :wind_direction
      t.integer :rainfall
      t.datetime :recorded_at

      t.timestamps
    end

    add_index :weather_snapshots, %i[session_id recorded_at]
  end
end
