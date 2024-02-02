# frozen_string_literal: true

FactoryBot.define do
  factory :permitted_route do
    carrier { 'S7' }
    origin_iata { 'UUS' }
    destination_iata { 'DME' }
    transfer_iata_codes { %w[OVB OVBNOZ] }
  end
end
