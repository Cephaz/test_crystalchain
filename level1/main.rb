# frozen_string_literal: true

require 'json'
require 'date'

def calculate_time_component(start_date, end_date, price_per_day)
  num_days = (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
  num_days * price_per_day
end

def calculate_distance_component(distance, price_per_km)
  distance * price_per_km
end

def calculate_total_price(time_component, distance_component)
  time_component + distance_component
end

def process_rental(rental, car)
  time_component = calculate_time_component(rental['start_date'], rental['end_date'], car['price_per_day'])
  distance_component = calculate_distance_component(rental['distance'], car['price_per_km'])
  total_price = calculate_total_price(time_component, distance_component)

  {
    'id' => rental['id'],
    'price' => total_price
  }
end

input = JSON.parse(File.read('data/input.json'))
rentals = input['rentals'].map do |rental|
  car = input['cars'].find { |c| c['id'] == rental['car_id'] }
  process_rental(rental, car)
end

output = { 'rentals' => rentals }
File.write('data/output.json', JSON.pretty_generate(output))
