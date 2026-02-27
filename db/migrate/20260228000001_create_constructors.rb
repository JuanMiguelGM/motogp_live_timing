# frozen_string_literal: true

class CreateConstructors < ActiveRecord::Migration[8.1]
  def change
    create_table :constructors do |t|
      t.string :name
      t.string :colour
      t.string :api_uuid

      t.timestamps
    end

    add_index :constructors, :api_uuid, unique: true
  end
end
