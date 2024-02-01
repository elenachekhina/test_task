# frozen_string_literal: true

class FlightSearcher
  MIN_CONNECTION_TIME = 480
  MAX_CONNECTION_TIME = 2880

  def search(params)
    params[:departure_from] = params[:departure_from].to_date
    params[:departure_to] = params[:departure_to].to_date.end_of_day

    options = PermittedRoute.find_by(
      carrier: params[:carrier],
      origin_iata: params[:origin_iata],
      destination_iata: params[:destination_iata]
    )

    return [] unless options

    routes = find_routes(params, options)
    routes.map do |route|
      path_information(route)
    end
  end

  private

  def find_routes(params, options)
    routes = []
    routes += find_direct_flight(params) if options.direct
    routes += find_flights_w_connections(params, options)
    routes
  end

  def find_direct_flight(params)
    Segment.flights(
      airline: params[:carrier],
      iata_from: params[:origin_iata],
      iata_to: params[:destination_iata],
      date_from: params[:departure_from],
      date_to: params[:departure_to]
    ).map { |segment| [segment] }
  end

  def find_flights_w_connections(params, options)
    options.transfer_iata_codes.map do |iatas|
      find_iata_flights(iatas.chars.each_slice(3).map(&:join), params)
    end.flatten(1)
  end

  def find_iata_flights(iatas, params)
    iata_i = 0

    flights = Segment.flights(
      airline: params[:carrier],
      iata_from: params[:origin_iata],
      iata_to: iatas[iata_i],
      date_from: params[:departure_from],
      date_to: params[:departure_to]
    )

    routes = []
    flights.each do |flight|
      find_next(flight, iata_i + 1, [flight], routes, iatas, params)
    end
    routes
  end

  def find_next(flight, iata_i, curr_route, routes, iatas, params)
    if flight.destination_iata == params[:destination_iata]
      routes << curr_route.dup
    else
      flights = Segment.connected_flights(flight:, iata: iatas[iata_i] || params[:destination_iata],
                                          sta: params[:departure_to], min_connection_time: MIN_CONNECTION_TIME,
                                          max_xonnection_time: MAX_CONNECTION_TIME)
      flights.each do |next_flight|
        curr_route << next_flight
        find_next(next_flight, iata_i + 1, curr_route, routes, iatas, params)
        curr_route.pop
      end
    end
    routes
  end

  def path_information(path)
    {
      origin_iata: path[0].origin_iata,
      destination_iata: path[-1].destination_iata,
      departure_time: path[0].std,
      arrival_time: path[-1].sta,
      segments:
        path.map do |segment|
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
