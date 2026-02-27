# frozen_string_literal: true

class CreateRaceDirectionMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :race_direction_messages do |t|
      t.references :session, null: false, foreign_key: true
      t.string :category
      t.string :flag
      t.string :scope
      t.integer :sector
      t.text :message
      t.integer :rider_number
      t.integer :lap_number
      t.datetime :recorded_at

      t.timestamps
    end

    add_index :race_direction_messages, %i[session_id recorded_at]
  end
end
