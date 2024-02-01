# frozen_string_literal: true

class SearchFlightsService
  def search(params)
    FlightSearcher.new.search(params).map do |flight|
      RouteParser.new.route_information_struct(flight)
    end
  end
end
