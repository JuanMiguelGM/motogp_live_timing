# frozen_string_literal: true

FactoryBot.define do
  factory :timing_entry do
    session
    rider
    position { 1 }
    gap_to_leader { '0.000' }
    interval { '0.000' }
    last_lap_time { '1:32.456' }
    best_lap_time { '1:31.234' }
    sector_1_time { '28.123' }
    sector_2_time { '38.456' }
    sector_3_time { '22.789' }
    tire_compound { 'SOFT' }
    tire_age { 5 }
    pit_stop_count { 0 }
    speed_trap { 340.0 }
    top_speed { 345.0 }
    total_laps { 25 }
    status { 'running' }
    best_lap_number { 15 }
  end
end
