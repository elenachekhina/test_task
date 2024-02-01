# frozen_string_literal: true

class Segment < ApplicationRecord
  scope :flights, lambda { |airline:, iata_from:, iata_to:, date_from:, date_to:|
    where(
      airline:,
      origin_iata: iata_from,
      destination_iata: iata_to,
      std: (date_from..date_to),
      sta: (..date_to)
    )
  }

  scope :connected_flights, lambda { |flight:, iata:, sta:, min_connection_time: 480, max_xonnection_time: 2880|
    where(
      airline: flight.airline,
      origin_iata: flight.destination_iata,
      destination_iata: iata,
      std: (flight.sta + min_connection_time * 60..flight.sta + max_xonnection_time * 60),
      sta: (..sta)
    )
  }
end
