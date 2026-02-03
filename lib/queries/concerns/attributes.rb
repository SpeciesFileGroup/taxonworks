# Helpers and facets for queries that loop through ATTRIBUTES
#
# !! Implementing filters must define ATTRIBUTES *before* the inclusion of this concern, like:
#
#  ATTRIBUTES = ::Loan.core_attributes.map(&:to_sym).freeze
#
# TODO: macro a method to explicitly set ATTRIBUTES and eliminate need for definition location dependency.
#       This may not be worth it as various models have slight exceptions.
module Queries::Concerns::Attributes
  include Queries::Helpers

  extend ActiveSupport::Concern

  def self.params
    [
      :attribute_exact_pair,
      :attribute_wildcard_pair,
      :wildcard_attribute,
      :any_value_attribute,
      :no_value_attribute,
      :attribute_name,
      :attribute_value,
      :attribute_value_type,
      :attribute_value_negator,
      :attribute_combine_logic,
      attribute_exact_pair: [],
      attribute_wildcard_pair: [],
      wildcard_attribute: [],
      any_value_attribute: [],
      no_value_attribute: [],
      attribute_name: [],
      attribute_value: [],
      attribute_value_type: [],
      attribute_value_negator: [],
      attribute_combine_logic: [],
    ]
  end

  included do

    self::ATTRIBUTES.each do |a|
      class_eval { attr_accessor a.to_sym }
    end

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

    # @param attribute_name
    # @return Array[String]
    #   Attribute names for row-based attribute filters.
    attr_accessor :attribute_name

    # @param attribute_value
    # @return Array[String]
    #   Values for row-based attribute filters.
    attr_accessor :attribute_value

    # @param attribute_value_type
    # @return Array[String]
    #   One of: exact, wildcard, any, no
    attr_accessor :attribute_value_type

    # @param attribute_value_negator
    # @return Array[Boolean]
    #   True to negate the value_type in this row.
    attr_accessor :attribute_value_negator

    # @param attribute_combine_logic
    # @return Array[Boolean]
    #   How to combine the results of the queries in this row and the next.
    attr_accessor :attribute_combine_logic

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

    def attribute_name
      [@attribute_name].flatten.compact
    end

    def attribute_value
      [@attribute_value].flatten
    end

    def attribute_value_type
      [@attribute_value_type].flatten.compact
    end

    def attribute_value_negator
      [@attribute_value_negator].flatten
    end

    def attribute_combine_logic
      [@attribute_combine_logic].flatten
    end
  end


  def set_attributes_params(params)
    @attribute_exact_pair = params[:attribute_exact_pair]
    @attribute_wildcard_pair = params[:attribute_wildcard_pair]
    @wildcard_attribute = params[:wildcard_attribute]
    @any_value_attribute = params[:any_value_attribute]
    @no_value_attribute = params[:no_value_attribute]

    set_attribute_row_params(params)

    self.class::ATTRIBUTES.each do |a|
      send("#{a}=", params[a.to_sym])
    end
  end

  def set_attribute_row_params(params)
    row_count = [params[:attribute_name]].flatten.compact.count
    return if (
      row_count == 0 ||
      [params[:attribute_value]].flatten.compact.count != row_count ||
      [params[:attribute_value_type]].flatten.compact.count != row_count ||
      tri_value_array(params[:attribute_value_negator]).length != row_count ||
      tri_value_array(params[:attribute_combine_logic]).length != row_count
    )

    @attribute_name =
      [params[:attribute_name]].flatten.compact
    @attribute_value =
      [params[:attribute_value]].flatten.compact
    @attribute_value_type =
      [params[:attribute_value_type]].flatten.compact
    @attribute_value_negator =
      tri_value_array(params[:attribute_value_negator])
    @attribute_combine_logic =
      tri_value_array(params[:attribute_combine_logic])
  end

  def self.and_clauses
    [
      :attribute_clauses,
      :attribute_or_clauses
    ]
  end

  def self.merge_clauses
    [
      :attribute_facet
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
        w = w.or(b)
      end
    end

    e = nil
    if attribute_exact_pair.present?
      arr = []
      attribute_exact_pair.each do |p|
        attr, v = [p[0], p[1]]
        arr.push table[attr].eq(v)
      end

      e = arr.shift
      arr.each do |b|
        e = e.or(b)
      end
    end

    return w.and(e) if w.present? && e.present?
    w || e
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

  def attribute_facet
    return nil if attribute_name.empty?

    queries = []
    attribute_value_type.map(&:to_sym).each_with_index do |value_type, i|
      name = attribute_name[i]
      next if name.blank?

      attribute = name.to_sym
      next unless self.class::ATTRIBUTES.include?(attribute)

      value = attribute_value[i]
      negator = attribute_value_negator[i]

      q = nil
      case value_type
      when :exact, :wildcard
        value_clause = if value_type == :exact
          table[attribute].eq(value)
        else
          Arel::Nodes::NamedFunction.new('CAST', [table[attribute].as('TEXT')])
            .matches("%#{value}%")
        end

        value_clause = value_clause.not if negator
        q = referenced_klass.where(value_clause)
      when :any, :no
        has_attr = (value_type == :any && !negator) || (value_type == :no && negator)
        value_clause = has_attr ? table[attribute].not_eq(nil) : table[attribute].eq(nil)
        q = referenced_klass.where(value_clause)
      end

      queries << q if q
    end

    return nil if queries.empty?

    q = queries.first
    attribute_combine_logic.each_with_index do |c, i|
      next_q = queries[i + 1]
      break if next_q.nil?

      if c.nil?
        q = referenced_klass_intersection([q, next_q])
      elsif c == true
        q = referenced_klass_union([q, next_q])
      else
        q = q.where.not(id: next_q)
      end
    end

    q
  end

end
