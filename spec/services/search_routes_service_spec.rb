# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchRoutesService, type: :service do
  let(:route_searcher) { instance_double(RouteSearcher) }
  let(:route) { instance_double(Route) }

  before do
    allow(RouteSearcher).to receive(:new).and_return(route_searcher)
    allow(route).to receive(:route_information_struct)
  end

  describe '#search' do
    context 'routes was found' do
      before do
        allow(route_searcher).to receive(:search).and_return([route])

        SearchRoutesService.new.search({})
      end

      it 'call RouteSearcher.new.search' do
        expect(route_searcher).to have_received(:search)
      end

      it 'call RouteParser.new.route_information_struct' do
        expect(route).to have_received(:route_information_struct)
      end
    end

    context 'routes was not found' do
      before do
        allow(route_searcher).to receive(:search).and_return([])

        SearchRoutesService.new.search({})
      end
      it 'call RouteSearcher.new.search' do
        expect(route_searcher).to have_received(:search)
      end

      it 'not call RouteParser.new.route_information_struct' do
        expect(route).to_not have_received(:route_information_struct)
      end
    end
  end
end
