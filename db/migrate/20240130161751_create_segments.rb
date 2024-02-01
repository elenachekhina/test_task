# frozen_string_literal: true

class CreateSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :segments do |t|
      t.string :airline
      t.string :segment_number
      t.string :origin_iata, null: false
      t.string :destination_iata, null: false
      t.datetime :std
      t.datetime :sta

      t.timestamps
    end
  end
end
