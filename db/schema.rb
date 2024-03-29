# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_240_130_162_612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'permitted_routes', force: :cascade do |t|
    t.string 'carrier', null: false
    t.string 'destination_iata', null: false
    t.boolean 'direct', default: true, null: false
    t.string 'origin_iata', null: false
    t.string 'transfer_iata_codes', default: [], array: true
    t.date 'created_at', default: '2024-01-30', null: false
    t.date 'updated_at', default: '2024-01-30', null: false
  end

  create_table 'segments', force: :cascade do |t|
    t.string 'airline'
    t.string 'segment_number'
    t.string 'origin_iata', null: false
    t.string 'destination_iata', null: false
    t.datetime 'std'
    t.datetime 'sta'
    t.date 'created_at', default: '2024-01-30', null: false
    t.date 'updated_at', default: '2024-01-30', null: false
  end
end
