# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.string :api_uuid
      t.string :session_type
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
      t.float :air_temperature
      t.float :track_temperature
      t.float :humidity
      t.string :weather_condition
      t.references :event, null: false, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end

    add_index :sessions, :api_uuid, unique: true
  end
end
