# frozen_string_literal: true

class CreatePermittedRoutes < ActiveRecord::Migration[7.1]
  def change
    create_table :permitted_routes do |t|
      t.string :carrier, null: false
      t.string :destination_iata, null: false
      t.boolean :direct, null: false, default: true
      t.string :origin_iata, null: false
      t.string :transfer_iata_codes, null: false, array: true, default: []

      t.timestamps
    end
  end
end
