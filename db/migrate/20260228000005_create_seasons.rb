# frozen_string_literal: true

class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.integer :year
      t.string :api_uuid
      t.boolean :current, default: false

      t.timestamps
    end

    add_index :seasons, :year, unique: true
  end
end
