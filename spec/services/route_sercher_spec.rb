# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RouteSearcher, type: :service do
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

    let(:searcher) { RouteSearcher.new }
    subject { searcher.search(params).map(&:segments) }

    let!(:permitted_route) { create(:permitted_route) }

    context 'when only direct flights are available' do
      context 'in time' do
        let!(:segment) { create(:segment) }

        it 'returns route with direct flight' do
          expect(subject).to eq([[segment]])
        end
      end

      context 'earlier time' do
        let!(:segment) { create(:segment, std: '2023-12-01'.to_datetime) }

        it 'returns empty array' do
          expect(subject).to eq([])
        end
      end

      context 'later time' do
        let!(:segment) { create(:segment, sta: '2024-01-05'.to_datetime) }

        it 'returns empty array' do
          expect(subject).to eq([])
        end
      end
    end

    context 'when only flights with connections are available' do
      context 'in time' do
        let!(:segment_1) do
          create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                           std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
        end

        context 'when time for connection is ok' do
          let!(:segment_2) do
            create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                             std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
          end

          it 'returns flight path with connections' do
            expect(subject).to eq([[segment_1, segment_2]])
          end
        end

        context 'when time for connection less' do
          let!(:segment_2) do
            create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                             std: segment_1.sta.to_datetime + (RouteSearcher::MIN_CONNECTION_TIME - 1) * 60, sta: '2024-01-02 10:20:00'.to_datetime)
          end

          it 'returns empty route list' do
            expect(subject).to eq([])
          end
        end

        context 'when time for connection more' do
          let!(:segment_2) do
            create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                             std: segment_1.sta.to_datetime + (RouteSearcher::MAX_CONNECTION_TIME + 1) * 60, sta: '2024-01-02 10:20:00'.to_datetime)
          end

          it 'returns empty route list' do
            expect(subject).to eq([])
          end
        end
      end

      context 'not in time' do
        context 'earlier first' do
          let!(:segment_1) do
            create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                             std: '2023-12-31 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
          end
          let!(:segment_2) do
            create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                             std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-01 20:20:00'.to_datetime)
          end

          it 'returns empty route list' do
            expect(subject).to eq([])
          end
        end

        context 'later last' do
          let!(:segment_1) do
            create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                             std: '2024-01-04 05:20:00'.to_datetime, sta: '2024-01-04 10:20:00'.to_datetime)
          end
          let!(:segment_2) do
            create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                             std: '2024-01-04 18:20:00'.to_datetime, sta: '2024-01-05 05:20:00'.to_datetime)
          end

          it 'returns empty route list' do
            expect(subject).to eq([])
          end
        end
      end

      context 'several connections' do
        let!(:segment_1) do
          create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                           std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
        end
        let!(:segment_2) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'NOZ',
                           std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
        end
        let!(:segment_3) do
          create(:segment, origin_iata: 'NOZ', destination_iata: 'DME',
                           std: '2024-01-02 18:20:00'.to_datetime, sta: '2024-01-02 20:20:00'.to_datetime)
        end

        it 'returns 3 segment route' do
          expect(subject).to eq([[segment_1, segment_2, segment_3]])
        end
      end

      context 'connection with two next segments' do
        let!(:segment_1) do
          create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                           std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
        end
        let!(:segment_2) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                           std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-02 10:20:00'.to_datetime)
        end
        let!(:segment_3) do
          create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                           std: '2024-01-02 23:20:00'.to_datetime, sta: '2024-01-03 02:20:00'.to_datetime)
        end

        it 'returns 3 segment route' do
          expect(subject).to eq([[segment_1, segment_2], [segment_1, segment_3]])
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
      let!(:segment_2) do
        create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                         std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-01 20:20:00'.to_datetime)
      end

      it 'returns routes with direct and flight with connection' do
        expect(subject).to eq([[segment_direct], [segment_1, segment_2]])
      end
    end
  end
end
