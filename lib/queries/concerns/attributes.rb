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
      :attribute_between_and_or,
      :attribute_exact_pair,
      :attribute_wildcard_pair,
      :wildcard_attribute,
      :any_value_attribute,
      :no_value_attribute,
      attribute_exact_pair: [],
      attribute_wildcard_pair: [],
      wildcard_attribute: [],
      any_value_attribute: [],
      no_value_attribute: [],
    ]
  end

  included do

    self::ATTRIBUTES.each do |a|
      class_eval { attr_accessor a.to_sym }
    end

    # @return [String]
    #  if 'and' then 'and' the result of each pair from attribute_wildcard_pair,
    #  otherwise 'or' those results.
    attr_accessor :attribute_between_and_or

    # @return [Array]
    #   values are [attribute, value] pairs that should match exactly - repeated
    #   attributes are ORed.
    attr_accessor :attribute_exact_pair

    # @return [Array]
    #   values are [attribute, value] pairs that should wildcard match -
    #   repeated attributes are ORed.
    attr_accessor :attribute_wildcard_pair

    # @return [Array]
    #  ATTRIBUTES listed here will all not-null records
    attr_accessor :any_value_attribute

    # @return [Array]
    #  ATTRIBUTES listed here will match null
    attr_accessor :no_value_attribute

    # @return [Array (Symbols)]
    #   values are ATTRIBUTES that should be wildcarded - attributes are not
    #   repeated.
    attr_accessor :wildcard_attribute

    def attribute_exact_pair
      return {} if @attribute_exact_pair.blank?

      split_repeated_pairs([@attribute_exact_pair].flatten.compact)
    end

    def attribute_wildcard_pair
      return {} if @attribute_wildcard_pair.blank?

      split_repeated_pairs([@attribute_wildcard_pair].flatten.compact)
    end

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
    @attribute_exact_pair = params[:attribute_exact_pair]
    @attribute_wildcard_pair = params[:attribute_wildcard_pair]
    @wildcard_attribute = params[:wildcard_attribute]
    @any_value_attribute = params[:any_value_attribute]
    @no_value_attribute = params[:no_value_attribute]
    @attribute_between_and_or = params[:attribute_between_and_or] || 'and'

    self.class::ATTRIBUTES.each do |a|
      send("#{a}=", params[a.to_sym])
    end
  end

  def self.and_clauses
    [
      :attribute_clauses,
      :attribute_or_clauses
    ]
  end

  def attribute_or_clauses
    return nil if attribute_wildcard_pair.empty? && attribute_exact_pair.empty?

    w = nil
    if attribute_wildcard_pair.present?
      arr = []
      attribute_wildcard_pair.each do |p|
        attr, v = [p[0], p[1]]
        arr.push Arel::Nodes::NamedFunction.new('CAST', [table[attr].as('TEXT')]).matches('%' + v.to_s + '%')
      end

      w = arr.shift
      arr.each do |b|
        if attribute_between_and_or == 'and'
          w = w.and(b)
        else
          w = w.or(b)
        end
      end
    end

    if attribute_exact_pair.present?
      arr = []
      attribute_exact_pair.each do |p|
        attr, v = [p[0], p[1]]
        arr.push table[attr].eq(v)
      end

      w = arr.shift if w.nil?
      arr.each do |b|
        if attribute_between_and_or == 'and'
          w = w.and(b)
        else
          w = w.or(b)
        end
      end
    end

    w
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
