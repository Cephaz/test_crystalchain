# frozen_string_literal: true

require 'json'
require 'date'

# id            :integer
# price_per_day :integer
# price_per_km  :integer
class Car
  attr_accessor :id, :price_per_day, :price_per_km

  def initialize(id, price_per_day, price_per_km)
    @id = id
    @price_per_day = price_per_day
    @price_per_km = price_per_km
  end
end

# id          :integer
# car_id      :integer
# start_date  :date
# end_date    :date
# distance    :integer
class Rental
  attr_accessor :id, :car, :start_date, :end_date, :distance

  def initialize(id, car, start_date, end_date, distance)
    @id = id
    @car = car
    @start_date = start_date
    @end_date = end_date
    @distance = distance
  end

  def calculate_time_component
    num_days = (@end_date - @start_date).to_i + 1
    num_days * @car.price_per_day
  end

  def calculate_distance_component
    @distance * @car.price_per_km
  end

  def calculate_total_price
    time_component = calculate_time_component
    distance_component = calculate_distance_component
    time_component + distance_component
  end

  def to_h
    {
      id: @id,
      price: calculate_total_price
    }
  end
end

input = JSON.parse(File.read('data/input.json'))

cars = {}
input['cars'].each do |car_json|
  car = Car.new(car_json['id'], car_json['price_per_day'], car_json['price_per_km'])
  cars[car.id] = car
end

rentals = input['rentals'].map do |rental_json|
  car = cars[rental_json['car_id']]
  start_date = Date.parse(rental_json['start_date'])
  end_date = Date.parse(rental_json['end_date'])
  rental = Rental.new(rental_json['id'], car, start_date, end_date, rental_json['distance'])
  rental.to_h
end

output = { 'rentals' => rentals }
File.write('data/output.json', JSON.pretty_generate(output))
