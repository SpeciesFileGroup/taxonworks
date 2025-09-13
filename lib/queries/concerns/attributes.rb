# Helpers and facets for queries that loop through ATTRIBUTES
#
# !! Implementing filters must define ATTRIBUTES *before* the inclusion of this concern, like:
#
#  ATTRIBUTES = ::Loan.core_attributes.map(&:to_sym).freeze
#
# TODO: macro a method to explicitly set ATTRIBUTES and eliminate need for definition location dependency.
#       This may not be worth it as various models have slight exceptions.
module Queries::Concerns::Attributes

  extend ActiveSupport::Concern

  def self.params
    [
      :wildcard_attribute,
      :any_value_attribute,
      :no_value_attribute,
      wildcard_attribute: [],
      any_value_attribute: [],
      no_value_attribute: [],
    ]
  end

  included do

    self::ATTRIBUTES.each do |a|
      class_eval { attr_accessor a.to_sym }
    end

    # @return [Array]
    #  ATTRIBUTES listed here will all not-null records
    attr_accessor :any_value_attribute

    # @return [Array]
    #  ATTRIBUTES listed here will match null
    attr_accessor :no_value_attribute

    # @return [Array (Symbols)]
    #   values are ATTRIBUTES that should be wildcarded
    attr_accessor :wildcard_attribute

    def wildcard_attribute
      [@wildcard_attribute].flatten.compact.uniq.map(&:to_sym)
    end

    def no_value_attribute
      [@no_value_attribute].flatten.compact.uniq.map(&:to_sym)
    end

    def any_value_attribute
      [@any_value_attribute].flatten.compact.uniq.map(&:to_sym)
    end
  end

  def set_attributes_params(params)
    @wildcard_attribute = params[:wildcard_attribute]
    @any_value_attribute = params[:any_value_attribute]
    @no_value_attribute = params[:no_value_attribute]

    self.class::ATTRIBUTES.each do |a|
      send("#{a}=", params[a.to_sym])
    end
  end

  def self.and_clauses
    [ :attribute_clauses ]
  end

  def attribute_clauses
    c = []
    self.class::ATTRIBUTES.each do |a|
      if any_value_attribute.include?(a)
        c.push table[a].not_eq(nil)
      elsif no_value_attribute.include?(a)
        c.push table[a].eq(nil)
      else
        v = send(a)
        if v.present?
          if wildcard_attribute.include?(a)
            c.push Arel::Nodes::NamedFunction.new('CAST', [table[a].as('TEXT')]).matches('%' + v.to_s + '%')
          else
            c.push table[a].eq(v)
          end
        end
      end
    end

    a = c.shift
    c.each do |b|
      a = a.and(b)
    end
    a
  end

end
