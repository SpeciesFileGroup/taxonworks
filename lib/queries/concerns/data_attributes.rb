# Linking DataAttribute to  queries that reference DataAttributes
#
# For filter queries:
# !! requires `set_data_attributes_params` be called in initialize()
#
module Queries::Concerns::DataAttributes
  include Queries::Helpers

  def self.params
    [
      :data_attributes, # API only

      :data_attribute_import_exact_pair,
      :data_attribute_import_exact_value,
      :data_attribute_import_predicate,
      :data_attribute_import_wildcard_value,
      :data_attribute_import_wildcard_pair,

      :data_attribute_exact_pair, # API only
      :data_attribute_exact_value, # API only
      :data_attribute_predicate_id, # API only
      :data_attribute_wildcard_pair, # API only
      :data_attribute_wildcard_value, # API only
      :data_attribute_without_predicate_id, # API only

      :data_attribute_predicate_row_id,
      :data_attribute_value,
      :data_attribute_value_negator,
      :data_attribute_value_type,
      :data_attribute_combine_logic,

      data_attribute_exact_pair: [], # API only
      data_attribute_exact_value: [], # API only
      data_attribute_predicate_id: [], # API only
      data_attribute_wildcard_pair: [], # API only
      data_attribute_wildcard_value: [], # API only
      data_attribute_without_predicate_id: [], # API only

      data_attribute_predicate_row_id: [],
      data_attribute_value: [],
      data_attribute_value_negator: [],
      data_attribute_value_type: [],
      data_attribute_combine_logic: [],

      data_attribute_import_wildcard_pair: [],
      data_attribute_import_exact_pair: [],
      data_attribute_import_exact_value: [],
      data_attribute_import_predicate: [],
      data_attribute_import_wildcard_value: [],
    ]
  end

  #  -- list 1 (predicate smart selector at top)
  #  Objects with predicate [ ] | `data_attribute_predicate_id`  -> Any button
  #  Objects without predicate [ ] | `data_attribute_without_predicate_id` -> Add button (with no value)
  #  Objects with [ predicate: value, predicate: value] `data_attribute_exact_pair`|`data_attribute_wildcard_pair` ->  Add button (with value), Exact [] checkbox (in list?)
  #
  #  -- list 2 (a second list)
  #  Objects with value [] | "With value (any predicate)" | `data_attribute_exact_value`|`data_attribute_wildcard_value` -> <type value> "Add", Exact []

  extend ActiveSupport::Concern

  included do

    # See corresponding versions for InternalAttributes
    attr_accessor :data_attribute_import_exact_pair
    attr_accessor :data_attribute_import_exact_value
    attr_accessor :data_attribute_import_predicate
    attr_accessor :data_attribute_import_wildcard_value
    attr_accessor :data_attribute_import_wildcard_pair

    # @param data_attribute_predicate_id [Integer, String, Array] of Predicate (CVT) ids
    # @return Array
    #  API only: match any record that has a data attribute with these predicate_ids
    attr_accessor :data_attribute_predicate_id

    # @param data_attribute_without_predicate_id [Integer, String, Array] of Predicate (CVT) ids
    # @return Array
    #  API only: match any record that does not have a data attribute with this predicate_id
    attr_accessor :data_attribute_without_predicate_id

    # @param data_attribute_exact_value [String, Array] of values
    # @return Array
    #  API only: match any record that matches a data_attribute with any of these exact values
    attr_accessor :data_attribute_exact_value

    # @param data_attribute_wildcard_value [String, Array] of values
    # @return Array
    #  API only: match any record that matches a data_attribute with any of these values, wildcarded
    attr_accessor :data_attribute_wildcard_value

    # @return [Hash]
    # @param [Array]
    #  API only: string formatted as predicate_id:value
    attr_accessor :data_attribute_exact_pair

    # @return [Hash]
    # @param [Array]
    #  API only: string formatted as predicate_id:value
    attr_accessor :data_attribute_wildcard_pair

    # @return [True, False, nil]
    #   API only: true - has a data_attribute
    #   API only: false - does not have a data_attribute
    #   API only: nil - not applied
    attr_accessor :data_attributes

    # @param data_attribute_predicate_row_id
    # @return Array[0 or positive integers]
    #   Row-based predicate id or 0 to mean 'any predicate'
    attr_accessor :data_attribute_predicate_row_id

    # @param data_attribute_value
    # @return Array[String]
    #   Row-based values of data attributes.
    attr_accessor :data_attribute_value

    # @param data_attribute_value_negator
    # @return Array[Boolean]
    #   Row-based value negator.
    attr_accessor :data_attribute_value_negator

    # @param data_attribute_value_type
    # @return Array[String]
    #   Row-based value types: exact, wildcard, any, no.
    attr_accessor :data_attribute_value_type

    # @param data_attribute_combine_logic
    # @return Array[Boolean]
    #   Row-based combine logic.
    attr_accessor :data_attribute_combine_logic

    def data_attribute_predicate_id
      [@data_attribute_predicate_id].flatten.compact
    end

    def data_attribute_without_predicate_id
      [@data_attribute_without_predicate_id].flatten.compact
    end

    def data_attribute_predicate_row_id
      [@data_attribute_predicate_row_id].flatten.compact
    end

    def data_attribute_exact_value
      [@data_attribute_exact_value].flatten.compact
    end

    def data_attribute_wildcard_value
      [@data_attribute_wildcard_value].flatten.compact
    end

    def data_attribute_value
      [@data_attribute_value].flatten.compact
    end

    def data_attribute_value_negator
      [@data_attribute_value_negator].flatten
    end

    def data_attribute_value_type
      [@data_attribute_value_type].flatten.compact
    end

    def data_attribute_combine_logic
      [@data_attribute_combine_logic].flatten
    end

    def data_attribute_import_wildcard_value
      [@data_attribute_import_wildcard_value].flatten.compact
    end

    def data_attribute_exact_pair
      return {} if @data_attribute_exact_pair.blank?
      if @data_attribute_exact_pair.kind_of?(Hash)
        @data_attribute_exact_pair
      else
        split_repeated_pairs([@data_attribute_exact_pair].flatten.compact)
      end
    end

    def data_attribute_wildcard_pair
      return {} if @data_attribute_wildcard_pair.blank?
      if @data_attribute_wildcard_pair.kind_of?(Hash)
        @data_attribute_wildcard_pair
      else
        split_repeated_pairs([@data_attribute_wildcard_pair].flatten.compact)
      end
    end

    def data_attribute_import_wildcard_pair
      return {} if @data_attribute_import_wildcard_pair.blank?
      if @data_attribute_import_wildcard_pair.kind_of?(Hash)
        @data_attribute_import_wildcard_pair
      else
        split_pairs([@data_attribute_import_wildcard_pair].flatten.compact)
      end
    end

    def data_attribute_import_exact_value
      [@data_attribute_import_exact_value].flatten.compact
    end

    def data_attribute_import_exact_pair
      return {} if @data_attribute_import_exact_pair.blank?
      if @data_attribute_import_exact_pair.kind_of?(Hash)
        @data_attribute_import_exact_pair
      else
        split_pairs([@data_attribute_import_exact_pair].flatten.compact)
      end
    end

    def data_attribute_import_predicate
      [@data_attribute_import_predicate].flatten.compact
    end
  end

  def set_data_attributes_params(params)
    @data_attribute_import_exact_pair = params[:data_attribute_import_exact_pair]
    @data_attribute_import_exact_value = params[:data_attribute_import_exact_value]
    @data_attribute_import_predicate = params[:data_attribute_import_predicate]
    @data_attribute_import_wildcard_value = params[:data_attribute_import_wildcard_value]

    @data_attribute_predicate_id = params[:data_attribute_predicate_id]
    @data_attribute_without_predicate_id = params[:data_attribute_without_predicate_id]
    @data_attribute_exact_value = params[:data_attribute_exact_value]
    @data_attribute_wildcard_value = params[:data_attribute_wildcard_value]

    @data_attribute_exact_pair = params[:data_attribute_exact_pair]
    @data_attribute_wildcard_pair = params[:data_attribute_wildcard_pair]
    @data_attribute_import_wildcard_pair = params[:data_attribute_import_wildcard_pair]
    @data_attributes = boolean_param(params, :data_attributes)

    row_count = [params[:data_attribute_predicate_row_id]].flatten.compact.count
    return if (
      row_count == 0 ||
      [params[:data_attribute_value]].flatten.compact.count != row_count ||
      [params[:data_attribute_value_type]].flatten.compact.count != row_count
    )

    negators = tri_value_array(params[:data_attribute_value_negator])
    negators = Array.new(row_count) if negators.empty? && params[:data_attribute_value_negator].nil?

    combine_logic = tri_value_array(params[:data_attribute_combine_logic])
    if combine_logic.empty? && params[:data_attribute_combine_logic].nil?
      combine_logic = Array.new(row_count)
    elsif combine_logic.length == row_count - 1
      combine_logic = combine_logic + [nil]
    end

    return if (
      negators.length != row_count ||
      combine_logic.length != row_count
    )

    @data_attribute_predicate_row_id =
      [params[:data_attribute_predicate_row_id]].flatten.compact
    @data_attribute_value =
      [params[:data_attribute_value]].flatten.compact
    @data_attribute_value_negator = negators
    @data_attribute_value_type =
      [params[:data_attribute_value_type]].flatten.compact
    @data_attribute_combine_logic = combine_logic
  end

  # @return [Arel::Table]
  def data_attribute_table
    ::DataAttribute.arel_table
  end

  def data_attribute_predicate_id_facet
    return nil if data_attribute_predicate_id.blank?
    referenced_klass.joins(:internal_attributes).where(data_attributes: {controlled_vocabulary_term_id: data_attribute_predicate_id})
  end

  def data_attribute_row_facet
    return nil if data_attribute_predicate_row_id.empty?

    queries = []
    data_attribute_value_type.map(&:to_sym).each_with_index do |value_type, i|
      id = data_attribute_predicate_row_id[i].to_i
      value = data_attribute_value[i]
      negator = data_attribute_value_negator[i]

      q = nil
      case value_type
      when :exact, :wildcard
        value_clause = if value_type == :exact
          data_attribute_table[:value].eq(value)
        else
          data_attribute_table[:value].matches("%#{value}%")
        end

        value_clause = value_clause.not if negator

        if id > 0
          value_clause = value_clause.and(
            data_attribute_table[:controlled_vocabulary_term_id].eq(id)
          )
        end

        q = referenced_klass
          .joins(:internal_attributes)
          .where(value_clause)
          .distinct

      when :any, :no
        has_attr = (value_type == :any && !negator) || (value_type == :no && negator)

        if id == 0 # any predicate
          q = has_attr ?
            referenced_klass.joins(:internal_attributes) :
            referenced_klass.left_joins(:internal_attributes)
              .where(data_attributes: { id: nil })
        else
          with_predicate = referenced_klass
            .joins(:internal_attributes)
            .where(data_attributes: { controlled_vocabulary_term_id: id })
          q = has_attr ? with_predicate : referenced_klass.where.not(id: with_predicate)
        end

        q.distinct
      end

      queries << q
    end

    return nil if queries.empty?

    q = queries.first
    data_attribute_combine_logic.each_with_index do |c, i|
      if c.nil?
        q = referenced_klass_intersection([q, queries[i + 1]])
      elsif c == true
        q = referenced_klass_union([q, queries[i + 1]])
      else
        q = q.where.not(id: queries[i + 1])
      end
    end

    q
  end

  def data_attribute_import_predicate_facet
    return nil if data_attribute_import_predicate.empty?
    referenced_klass.joins(:import_attributes).where(data_attributes: {import_predicate: data_attribute_import_predicate})
  end

  def data_attribute_without_predicate_id_facet
    return nil if data_attribute_without_predicate_id.blank?
    not_these = referenced_klass.left_joins(:internal_attributes).where(data_attributes: {controlled_vocabulary_term_id: data_attribute_without_predicate_id})

    # a Not exists without using .exists
    s = 'WITH not_these AS (' + not_these.to_sql + ') ' +
      referenced_klass.joins("LEFT JOIN not_these AS not_these1 ON not_these1.id = #{table.name}.id")
      .where('not_these1.id IS NULL').to_sql

    referenced_klass.from("(#{s}) as #{table.name}")
  end

  # TODO: get rid of this
  def wildcard_value(value)
    '%' + value.to_s.strip.gsub(/\s+/, '%') + '%'
  end

  def value_facet
    return nil if data_attribute_exact_value.blank?  && data_attribute_wildcard_value.blank?

    a,b = nil, nil

    if data_attribute_wildcard_value.present?
      v = data_attribute_wildcard_value.collect{|a| wildcard_value(a) } # TODO: should be standardized much earlier on
      a = data_attribute_table[:value].matches_any(v)
    end

    b = data_attribute_table[:value].in(data_attribute_exact_value) if data_attribute_exact_value.present?

    q = referenced_klass.joins(:internal_attributes)

    if a && b
      q.where(a.or(b))
    elsif a
      q.where(a)
    elsif b
      q.where(b)
    else
      nil
    end
  end

  def import_value_facet
    return nil if data_attribute_import_exact_value.blank? && data_attribute_import_wildcard_value.blank?

    a,b = nil, nil

    if data_attribute_import_wildcard_value.present?
      v = data_attribute_import_wildcard_value.collect{|z| wildcard_value(z) } # TODO: should be standardized much earlier on
      a = data_attribute_table[:value].matches_any(v)
    end

    b = data_attribute_table[:value].in(data_attribute_import_exact_value) if data_attribute_import_exact_value.present?

    q = referenced_klass.joins(:import_attributes)

    if a && b
      q.where(a.or(b))
    elsif a
      q.where(a)
    elsif b
      q.where(b)
    else
      nil
    end
  end

  def data_attribute_wildcard_pair_facet
    return nil if data_attribute_wildcard_pair.blank?
    a = []
    data_attribute_wildcard_pair.each do |k,v|
      a.push data_attribute_table[:controlled_vocabulary_term_id].eq(k).and( data_attribute_table[:value].matches(wildcard_value(v)) )
    end
    w = a.shift
    a.each do |c|
      w = w.or(c)
    end

    referenced_klass.joins(:internal_attributes).where(w).distinct
  end

  def data_attribute_import_wildcard_pair_facet
    return nil if data_attribute_import_wildcard_pair.blank?
    a = []
    data_attribute_import_wildcard_pair.each do |k,v|
      a.push data_attribute_table[:import_predicate].eq(k).and( data_attribute_table[:value].matches(wildcard_value(v)) )
    end
    w = a.shift
    a.each do |c|
      w = w.or(c)
    end

    referenced_klass.joins(:import_attributes).where(w)
  end

  def data_attribute_exact_pair_facet
    return nil if data_attribute_exact_pair.blank?
    a = []
    data_attribute_exact_pair.each do |k,v|
      a.push data_attribute_table[:controlled_vocabulary_term_id].eq(k).and( data_attribute_table[:value].eq(v) )
    end
    w = a.shift
    a.each do |c|
      w = w.or(c)
    end

    referenced_klass.joins(:internal_attributes).where(w).distinct
  end

  def data_attribute_import_exact_pair_facet
    return nil if data_attribute_import_exact_pair.blank?
    a = []
    data_attribute_import_exact_pair.each do |k,v|
      a.push data_attribute_table[:import_predicate].eq(k).and( data_attribute_table[:value].eq(v) )
    end
    w = a.shift
    a.each do |c|
      w = w.or(c)
    end

    referenced_klass.joins(:import_attributes).where(w)
  end

  def data_attributes_facet
    return nil if data_attributes.nil?
    if data_attributes
      referenced_klass.joins(:data_attributes).distinct
    else
      referenced_klass.where.missing(:data_attributes)
    end
  end

  # TODO: this as class method is bad,
  #  it prevents us from adding optimizing logic
  #  that restricts the number of clauses
  def self.merge_clauses
    [
      :data_attribute_import_exact_pair_facet,
      :data_attribute_exact_pair_facet,
      :data_attribute_import_predicate_facet,
      :data_attribute_predicate_id_facet,
      :data_attribute_row_facet,
      :data_attribute_wildcard_pair_facet,
      :data_attribute_import_wildcard_pair_facet,
      :data_attribute_without_predicate_id_facet,
      :data_attributes_facet,
      :value_facet,
      :import_value_facet
    ]
  end

end
