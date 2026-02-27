# frozen_string_literal: true

class CreateTimingEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :timing_entries do |t|
      t.references :session, null: false, foreign_key: true
      t.references :rider, null: false, foreign_key: true
      t.integer :position
      t.string :gap_to_leader
      t.string :interval
      t.string :last_lap_time
      t.string :best_lap_time
      t.integer :best_lap_number
      t.integer :total_laps
      t.string :sector_1_time
      t.string :sector_2_time
      t.string :sector_3_time
      t.boolean :sector_1_pb
      t.boolean :sector_2_pb
      t.boolean :sector_3_pb
      t.boolean :sector_1_sb
      t.boolean :sector_2_sb
      t.boolean :sector_3_sb
      t.string :tire_compound
      t.integer :tire_age
      t.integer :pit_stop_count
      t.float :speed_trap
      t.float :top_speed
      t.string :status

      t.timestamps
    end

    add_index :timing_entries, %i[session_id rider_id], unique: true
  end
end
