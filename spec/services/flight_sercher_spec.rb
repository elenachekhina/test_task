# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlightSearcher, type: :service do
  describe '#search' do
    let(:params) do
      {
        carrier: 'S7',
        origin_iata: 'UUS',
        destination_iata: 'DME',
        departure_from: '2024-01-01',
        departure_to: '2024-01-02'
      }
    end

    let!(:permitted_route) { create(:permitted_route) }

    context 'when only direct flights are available' do
      let!(:segment) { create(:segment) }

      it 'returns direct flight paths' do
        searcher = FlightSearcher.new
        expect(searcher.search(params)[0].slice(:departure_time, :arrival_time)).to eq({
                                                                                         departure_time: '2024-01-01 05:20:00'.to_datetime,
                                                                                         arrival_time: '2024-01-01 15:20:00'.to_datetime
                                                                                       })
      end
    end

    context 'when only flights with connections are available' do
      let!(:segment_1) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                         std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
      end

      context 'when time for connection is ok' do
        let!(:segment_2) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                           std: '2024-01-01 19:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
        end

        it 'returns flight paths with connections' do
          searcher = FlightSearcher.new
          expect(searcher.search(params)[0].slice(:departure_time, :arrival_time)).to eq({
                                                                                           departure_time: '2024-01-01 05:20:00'.to_datetime,
                                                                                           arrival_time: '2024-01-02 10:20:00'.to_datetime
                                                                                         })
        end
      end

      context 'when time for connection is not ok' do
        let!(:segment_2) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                           std: '2024-01-01 17:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
        end

        it 'returns empty list of flight paths' do
          searcher = FlightSearcher.new
          expect(searcher.search(params)).to eq([])
        end
      end
    end
  end
end
