require 'minitest/spec'
require 'minitest/autorun'

require_relative 'before' if ENV['BEFORE']
require_relative 'after' unless ENV['BEFORE']

describe Student do
  it 'has a grade for all three terms' do
    student = Student.new
    student.set_all_grades_to 10

    _(student.first_term_grade).must_equal 10
    _(student.second_term_grade).must_equal 10
    _(student.third_term_grade).must_equal 10
  end
end
