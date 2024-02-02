# frozen_string_literal: true

class Route
  attr_reader :segments

  def initialize(segments)
    @segments = segments.dup
  end

  def route_information_struct
    {
      origin_iata:,
      destination_iata:,
      departure_time:,
      arrival_time:,
      segments:
        @segments.map do |segment|
          segment_information_struct(segment)
        end
    }
  end

  private

  def origin_iata
    @segments.first.origin_iata
  end

  def origin_iata
    @segments.last.origin_iata
  end

  def destination_iata
    @segments.last.destination_iata
  end

  def departure_time
    @segments.first.std
  end

  def arrival_time
    @segments.last.sta
  end

  def segment_information_struct(segment)
    {
      carrier: segment.airline,
      segment_number: segment.segment_number,
      origin_iata: segment.origin_iata,
      destination_iata: segment.destination_iata,
      std: segment.std,
      sta: segment.sta
    }
  end
end
