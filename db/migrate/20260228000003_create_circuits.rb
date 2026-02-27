# frozen_string_literal: true

class CreateCircuits < ActiveRecord::Migration[8.1]
  def change
    create_table :circuits do |t|
      t.string :api_uuid
      t.string :name
      t.string :short_name
      t.string :country
      t.string :country_iso
      t.text :track_coordinates_json
      t.text :svg_data

      t.timestamps
    end

    add_index :circuits, :api_uuid, unique: true
  end
end
