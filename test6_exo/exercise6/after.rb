# frozen_string_literal: true

class Term
  attr_accessor :assiduity, :test, :behavior

  def initialize(assiduity = 0, test = 0, behavior = 0)
    @assiduity = assiduity
    @test = test
    @behavior = behavior
  end

  def average
    (@assiduity + @test + @behavior) / 3
  end
end

class Student
  attr_accessor :terms

  def initialize
    @first_term = Term.new
    @second_term = Term.new
    @third_term = Term.new
  end

  def set_all_grades_to(grade)
    [@first_term, @second_term, @third_term].each do |term|
      term.assiduity = grade
      term.test = grade
      term.behavior = grade
    end
  end

  def first_term_grade
    average_for(@first_term)
  end

  def second_term_grade
    average_for(@second_term)
  end

  def third_term_grade
    average_for(@third_term)
  end

  private

  def average_for(term)
    term.average
  end
end
