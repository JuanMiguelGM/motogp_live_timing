# frozen_string_literal: true

class CreateRiders < ActiveRecord::Migration[8.1]
  def change
    create_table :riders do |t|
      t.integer :number
      t.string :full_name
      t.string :name_acronym
      t.string :headshot_url
      t.string :api_uuid
      t.integer :legacy_id
      t.string :country_iso
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
