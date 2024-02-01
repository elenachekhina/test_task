# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RouteParser, type: :service do
  describe '#route_information_struct' do
    context 'not empty route with direct flight' do
      let(:segment) { create(:segment) }
      let(:route) { [segment] }
      it 'returns route as a struct' do
        expect(RouteParser.new.route_information_struct(route)).to eq(
          {
            origin_iata: segment.origin_iata,
            destination_iata: segment.destination_iata,
            departure_time: segment.std,
            arrival_time: segment.sta,
            segments: [{
              carrier: segment.airline,
              segment_number: segment.segment_number,
              origin_iata: segment.origin_iata,
              destination_iata: segment.destination_iata,
              std: segment.std,
              sta: segment.sta
            }]
          }
        )
      end
    end

    context 'not empty route with connected flight' do
      let!(:segment_1) do
        create(:segment, origin_iata: 'UUS', destination_iata: 'OVB',
                         std: '2024-01-01 05:20:00'.to_datetime, sta: '2024-01-01 10:20:00'.to_datetime)
      end
      let!(:segment_2) do
        create(:segment, origin_iata: 'OVB', destination_iata: 'DME',
                         std: '2024-01-01 18:20:00'.to_datetime, sta: '2024-01-01 20:20:00'.to_datetime)
      end
      let(:route) { [segment_1, segment_2] }
      it 'returns route as a struct' do
        expect(RouteParser.new.route_information_struct(route)).to eq(
          {
            origin_iata: segment_1.origin_iata,
            destination_iata: segment_2.destination_iata,
            departure_time: segment_1.std,
            arrival_time: segment_2.sta,
            segments: [{
              carrier: segment_1.airline,
              segment_number: segment_1.segment_number,
              origin_iata: segment_1.origin_iata,
              destination_iata: segment_1.destination_iata,
              std: segment_1.std,
              sta: segment_1.sta
            }, {
              carrier: segment_2.airline,
              segment_number: segment_2.segment_number,
              origin_iata: segment_2.origin_iata,
              destination_iata: segment_2.destination_iata,
              std: segment_2.std,
              sta: segment_2.sta
            }]
          }
        )
      end
    end

    context 'empty route' do
      let(:route) { [] }
      it 'returns nil' do
        expect(RouteParser.new.route_information_struct(route)).to eq(nil)
      end
    end
  end
end
