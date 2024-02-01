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
        departure_to: '2024-01-04'
      }
    end

    let(:searcher) { FlightSearcher.new }
    subject { searcher.search(params) }

    let!(:permitted_route) { create(:permitted_route) }

    context 'when only direct flights are available' do
      let!(:segment_1) { create(:segment) }
      let!(:segment_2) { create(:segment, sta: '2024-01-05'.to_datetime) }

      it 'returns direct flight path' do
        expect(subject).to eq([[segment_1]])
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

        it 'returns flight path with connections' do
          expect(subject).to eq([[segment_1, segment_2]])
        end
      end

      context 'when time for connection is not ok' do
        let!(:segment_2) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                           std: '2024-01-01 17:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
        end

        it 'returns empty list of flight paths' do
          expect(subject).to eq([])
        end
      end
    end

    context 'when direct and flights with connections are available' do
      let!(:segment_direct) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'DME',
                         std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
      end
      let!(:segment_1) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                         std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
      end
      let!(:segment_1_1) do
        create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                         std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-01 20:20:00'.to_datetime)
      end
      let!(:segment_1_2) do
        create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                         std: '2024-01-01 19:20:00'.to_datetime, sta: '2024-01-01 21:20:00'.to_datetime)
      end

      it 'returns list with direct and flight with connection' do
        expect(subject).to eq([[segment_direct], [segment_1, segment_1_1], [segment_1, segment_1_2]])
      end
    end

    context 'when direct and flights with connections out of time' do
      let!(:segment_direct_out_of_time) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'DME',
                         std: '2024-01-05 05:20:00'.to_datetime, sta: '2024-01-05 10:20:00'.to_datetime)
      end
      let!(:segment_1) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                         std: '2024-01-04 05:20:00'.to_datetime, sta: '2024-01-04 10:20:00'.to_datetime)
      end
      let!(:segment_1_2_out_of_time) do
        create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                         std: '2024-01-05 19:20:00'.to_datetime, sta: '2024-01-05 21:20:00'.to_datetime)
      end

      it 'returns empty list' do
        expect(subject).to eq([])
      end
    end
  end
end
