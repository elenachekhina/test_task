# frozen_string_literal: true

class SearchRoutesService
  def search(params)
    RouteSearcher.new.search(params).map(&:route_information_struct)
  end
end
