# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :colour
      t.string :api_uuid
      t.references :constructor, foreign_key: true

      t.timestamps
    end
  end
end
