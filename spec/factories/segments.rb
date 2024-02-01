# frozen_string_literal: true

FactoryBot.define do
  factory :segment do
    airline { 'S7' }
    segment_number { '1234' }
    origin_iata { 'UUS' }
    destination_iata { 'DME' }
    std { '2024-01-01 05:20:00'.to_datetime }
    sta { '2024-01-01 15:20:00'.to_datetime }
  end
end
