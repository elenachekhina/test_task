# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchFlightsService, type: :service do
  let(:flight_searcher) { instance_double(FlightSearcher) }
  let(:route_parser) { instance_double(RouteParser) }

  before do
    allow(FlightSearcher).to receive(:new).and_return(flight_searcher)

    allow(RouteParser).to receive(:new).and_return(route_parser)
    allow(route_parser).to receive(:route_information_struct)
  end

  describe '#search' do
    context 'routes was found' do
      before do
        allow(flight_searcher).to receive(:search).and_return([create(:segment)])

        SearchFlightsService.new.search({})
      end

      it 'call FlightSearcher.new.search' do
        expect(flight_searcher).to have_received(:search)
      end

      it 'call RouteParser.new.route_information_struct' do
        expect(route_parser).to have_received(:route_information_struct)
      end
    end

    context 'routes was not found' do
      before do
        allow(flight_searcher).to receive(:search).and_return([])

        SearchFlightsService.new.search({})
      end
      it 'call FlightSearcher.new.search' do
        expect(flight_searcher).to have_received(:search)
      end

      it 'not call RouteParser.new.route_information_struct' do
        expect(route_parser).to_not have_received(:route_information_struct)
      end
    end
  end
end
