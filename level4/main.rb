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

# id              :integer
# car_id          :integer
# start_date      :date
# end_date        :date
# distance        :integer
class Rental
  attr_accessor :id, :car, :start_date, :end_date, :distance

  PRICE_DECREASES = [
    { threshold: 1, discount: 0.1 },  # 10%
    { threshold: 4, discount: 0.3 },  # 30%
    { threshold: 10, discount: 0.5 }  # 50%
  ].freeze

  FEE_TYPES = [
    { who: 'driver', type: 'debit', method: :total_price },
    { who: 'owner', type: 'credit', method: :owner_amount },
    { who: 'insurance', type: 'credit', method: :insurance_fee },
    { who: 'assistance', type: 'credit', method: :assistance_fee },
    { who: 'drivy', type: 'credit', method: :drivy_fee }
  ].freeze

  def initialize(id, car, start_date, end_date, distance)
    @id = id
    @car = car
    @start_date = start_date
    @end_date = end_date
    @distance = distance
  end

  def calculate_time_component
    num_days = calculate_num_days
    total_time_component = 0

    (1..num_days).each do |day|
      applicable_discount = PRICE_DECREASES.select { |d| day > d[:threshold] }.last
      discount = applicable_discount ? applicable_discount[:discount] : 0
      daily_price = @car.price_per_day * (1 - discount)
      total_time_component += daily_price
    end

    total_time_component.round
  end

  def calculate_distance_component
    @distance * @car.price_per_km
  end

  def total_price
    @total_price ||= calculate_time_component + calculate_distance_component
  end

  def commission
    @commission ||= (total_price * 0.3).round
  end

  def insurance_fee
    @insurance_fee ||= (commission * 0.5).round
  end

  def assistance_fee
    @assistance_fee ||= calculate_num_days * 100
  end

  def drivy_fee
    @drivy_fee ||= commission - insurance_fee - assistance_fee
  end

  def owner_amount
    @owner_amount ||= total_price - commission
  end

  def to_h
    {
      id: @id,
      actions: FEE_TYPES.map do |fee|
        {
          who: fee[:who],
          type: fee[:type],
          amount: send(fee[:method])
        }
      end
    }
  end

  private

  def calculate_num_days
    (@end_date - @start_date).to_i + 1
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
