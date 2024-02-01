# frozen_string_literal: true

class FlightSearcher
  def search(params)
    @params = params
    @options = PermittedRoute.find_by(
      carrier: params[:carrier],
      origin_iata: params[:origin_iata],
      destination_iata: params[:destination_iata]
    )

    routes = []
    routes += find_direct_flight if @options&.direct
    routes += find_flights_w_connections if @options
    routes
  end

  private

  def find_direct_flight
    Segment.flights(
      airline: @params[:carrier],
      iata_from: @params[:origin_iata],
      iata_to: @params[:destination_iata],
      date_from: @params[:departure_from],
      date_to: @params[:departure_to]
    ).map { |segment| [segment] }
  end

  def find_flights_w_connections
    @options.transfer_iata_codes[1...-1].split(', ').map do |iatas|
      find_iata_flights(iatas)
    end.flatten(1)
  end

  def find_iata_flights(iatas)
    @iatas = iatas.chars.each_slice(3).map(&:join)
    iata_i = 0

    flights = Segment.flights(
      airline: @params[:carrier],
      iata_from: @params[:origin_iata],
      iata_to: @iatas[iata_i],
      date_from: @params[:departure_from],
      date_to: @params[:departure_to]
    )

    routes = []
    flights.each do |flight|
      find_next(flight, iata_i + 1, [flight], routes)
    end
    routes
  end

  def find_next(flight, iata_i, curr_route, routes)
    if flight.destination_iata == @params[:destination_iata]
      routes << curr_route.dup
    else
      flights = Segment.connected_flights(flight:, iata: @iatas[iata_i] || @params[:destination_iata],
                                          sta: @params[:departure_to])
      flights.each do |next_flight|
        curr_route << next_flight
        find_next(next_flight, iata_i + 1, curr_route, routes)
        curr_route.pop
      end
    end
    routes
  end
end
