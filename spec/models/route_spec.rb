# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segment, type: :class do
  describe '#route_information_struct' do
    let(:segment_first) { create(:segment, origin_iata: 'FRA', destination_iata: 'PRG') }
    let(:segment_last) { create(:segment, origin_iata: 'PRG', destination_iata: 'SVX') }
    let(:segments) { [segment_first, segment_last] }

    let(:route) { Route.new([segment_first, segment_last]) }

    it 'returns route in struct format' do
      expect(route.route_information_struct).to eq({
                                                     origin_iata: segments.first.origin_iata,
                                                     destination_iata: segments.last.destination_iata,
                                                     departure_time: segments.first.std,
                                                     arrival_time: segments.last.sta,
                                                     segments: [{
                                                       carrier: segments.first.airline,
                                                       segment_number: segments.first.segment_number,
                                                       origin_iata: segments.first.origin_iata,
                                                       destination_iata: segments.first.destination_iata,
                                                       std: segments.first.std,
                                                       sta: segments.first.sta
                                                     }, {
                                                       carrier: segments.last.airline,
                                                       segment_number: segments.last.segment_number,
                                                       origin_iata: segments.last.origin_iata,
                                                       destination_iata: segments.last.destination_iata,
                                                       std: segments.last.std,
                                                       sta: segments.last.sta
                                                     }]
                                                   })
    end
  end
end
