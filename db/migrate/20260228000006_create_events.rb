# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :api_uuid
      t.string :name
      t.string :official_name
      t.date :start_date
      t.date :end_date
      t.boolean :finished, default: false
      t.references :season, null: false, foreign_key: true
      t.references :circuit, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :api_uuid, unique: true
  end
end
