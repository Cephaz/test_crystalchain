# frozen_string_literal: true

require 'json'
require 'date'
require 'ostruct'

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

def calculate_num_days(start_date, end_date)
  (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
end

def calculate_time_component(start_date, end_date, price_per_day)
  num_days = calculate_num_days(start_date, end_date)
  total_time_component = 0

  (1..num_days).each do |day|
    applicable_discount = PRICE_DECREASES.select { |d| day > d[:threshold] }.last
    discount = applicable_discount ? applicable_discount[:discount] : 0
    daily_price = price_per_day * (1 - discount)
    total_time_component += daily_price
  end

  total_time_component.round
end

def calculate_distance_component(distance, price_per_km)
  distance * price_per_km
end

def calculate_total_price(time_component, distance_component)
  time_component + distance_component
end

def calculate_commission(total_price, num_days)
  commission = (total_price * 0.3).round
  insurance_fee = (commission * 0.5).round
  assistance_fee = num_days * 100
  drivy_fee = commission - insurance_fee - assistance_fee

  {
    insurance_fee: insurance_fee,
    assistance_fee: assistance_fee,
    drivy_fee: drivy_fee
  }
end

def calculate_owner_amount(total_price, commission_details)
  total_price - commission_details.values.sum
end

def build_actions(context)
  FEE_TYPES.map do |fee_type|
    amount = context.send(fee_type[:method])
    { who: fee_type[:who], type: fee_type[:type], amount: amount }
  end
end

def process_rental(rental, car)
  num_days = calculate_num_days(rental['start_date'], rental['end_date'])
  time_component = calculate_time_component(rental['start_date'], rental['end_date'], car['price_per_day'])
  distance_component = calculate_distance_component(rental['distance'], car['price_per_km'])
  total_price = calculate_total_price(time_component, distance_component)
  commission_details = calculate_commission(total_price, num_days)
  owner_amount = calculate_owner_amount(total_price, commission_details)

  context = OpenStruct.new(
    total_price: total_price,
    owner_amount: owner_amount,
    insurance_fee: commission_details[:insurance_fee],
    assistance_fee: commission_details[:assistance_fee],
    drivy_fee: commission_details[:drivy_fee]
  )
  {
    id: rental['id'],
    actions: build_actions(context)
  }
end

input = JSON.parse(File.read('data/input.json'))
rentals = input['rentals'].map do |rental|
  car = input['cars'].find { |c| c['id'] == rental['car_id'] }
  process_rental(rental, car)
end

output = { 'rentals' => rentals }
File.write('data/output.json', JSON.pretty_generate(output))
