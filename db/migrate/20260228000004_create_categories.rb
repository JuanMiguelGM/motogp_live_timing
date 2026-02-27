# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :api_uuid
      t.integer :legacy_id

      t.timestamps
    end

    add_index :categories, :api_uuid, unique: true
  end
end
