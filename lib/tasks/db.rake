# frozen_string_literal: true

require 'csv'

namespace :db do
  task import: :environment do
    Segment.destroy_all
    CSV.foreach('db/data/segments.csv') do |row|
      Segment.create({ airline: row[0], segment_number: row[1], origin_iata: row[2], destination_iata: row[3],
                       std: row[4], sta: row[5] })
    end

    PermittedRoute.destroy_all
    CSV.foreach('db/data/permitted_routes.csv') do |row|
      PermittedRoute.create({ carrier: row[0], origin_iata: row[1], destination_iata: row[2], direct: row[3],
                              transfer_iata_codes: row[4][1...-1].split(', ') })
    end
  end
end
