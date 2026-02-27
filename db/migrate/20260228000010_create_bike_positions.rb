# frozen_string_literal: true

class CreateBikePositions < ActiveRecord::Migration[8.1]
  def change
    create_table :bike_positions do |t|
      t.references :session, null: false, foreign_key: true
      t.references :rider, null: false, foreign_key: true
      t.float :x
      t.float :y
      t.float :z
      t.datetime :recorded_at

      t.timestamps
    end

    add_index :bike_positions, %i[session_id rider_id], unique: true
  end
end
