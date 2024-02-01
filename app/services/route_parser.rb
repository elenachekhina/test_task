# frozen_string_literal: true

class RouteParser
  def route_information_struct(route)
    return nil if route.empty?

    {
      origin_iata: route[0].origin_iata,
      destination_iata: route[-1].destination_iata,
      departure_time: route[0].std,
      arrival_time: route[-1].sta,
      segments:
        route.map do |segment|
          {
            carrier: segment.airline,
            segment_number: segment.segment_number,
            origin_iata: segment.origin_iata,
            destination_iata: segment.destination_iata,
            std: segment.std,
            sta: segment.sta
          }
        end
    }
  end
end
