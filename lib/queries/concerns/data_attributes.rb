# Linking DataAttribute to  queries that reference DataAttributes
#
# For filter queries:
# !! requires `set_data_attributes_params` be called in initialize()
#
module Queries::Concerns::DataAttributes
  include Queries::Helpers

  def self.params
    [
      :data_attributes,

      :data_attribute_import_exact_pair,
      :data_attribute_import_exact_value,
      :data_attribute_import_predicate,
      :data_attribute_import_wildcard_value,
      :data_attribute_import_wildcard_pair,

      :data_attribute_exact_pair,
      :data_attribute_exact_value,
      :data_attribute_predicate_id,
      :data_attribute_wildcard_pair,
      :data_attribute_wildcard_value,
      :data_attribute_without_predicate_id,

      data_attribute_exact_pair: [],
      data_attribute_exact_value: [],
      data_attribute_predicate_id: [],
      data_attribute_wildcard_pair: [],
      data_attribute_wildcard_value: [],
      data_attribute_without_predicate_id: [],

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
    attr_accessor :data_attribute_wildcard_pair

    # @param data_attribute_predicate_id [Integer, String, Array] of Predicate (CVT) ids
    # @return Array
    #  match any record that has a data attribute with these predicate_ids
    attr_accessor :data_attribute_predicate_id

    # @param data_attribute_without_predicate_id [Integer, String, Array] of Predicate (CVT) ids
    # @return Array
    #  match any record that does not have a data attribute with this predicate_id
    attr_accessor :data_attribute_without_predicate_id

    # @param data_attribute_exact_value [String, Array] of values
    # @return Array
    #  match any record that matches a data_attribute with any of these exact values
    attr_accessor :data_attribute_exact_value

    # @param data_attribute_wildcard_value [String, Array] of values
    # @return Array
    #  match any record that matches a data_attribute with any of these values, wildcarded
    attr_accessor :data_attribute_wildcard_value

    # @return [Hash]
    # @param [Array]
    #  string formatted as predicate_id:value
    attr_accessor :data_attribute_exact_pair

    # @return [Hash]
    # @param [Array]
    #  string formatted as predicate_id:value
    attr_accessor :data_attribute_wildcard_pair

    # @return [True, False, nil]
    #   true - has a data_attribute
    #   false - does not have a data_attribute
    #   nil - not applied
    attr_accessor :data_attributes

    def data_attribute_predicate_id
      [@data_attribute_predicate_id].flatten.compact
    end

    def data_attribute_without_predicate_id
      [@data_attribute_without_predicate_id].flatten.compact
    end

    def data_attribute_exact_value
      [@data_attribute_exact_value].flatten.compact
    end

    def data_attribute_wildcard_value
      [@data_attribute_wildcard_value].flatten.compact
    end

    def data_attribute_import_wildcard_value
      [@data_attribute_import_wildcard_value].flatten.compact
    end

    def data_attribute_exact_pair
      return {} if @data_attribute_exact_pair.blank?
      if @data_attribute_exact_pair.kind_of?(Hash)
        @data_attribute_exact_pair
      else
        split_pairs([@data_attribute_exact_pair].flatten.compact)
      end
    end

    def data_attribute_wildcard_pair
      return {} if @data_attribute_wildcard_pair.blank?
      if @data_attribute_wildcard_pair.kind_of?(Hash)
        @data_attribute_wildcard_pair
      else
        split_pairs([@data_attribute_wildcard_pair].flatten.compact)
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

    def split_pairs(pairs)
      h = {}
      pairs.each do |p|
        k, v = p.split(':', 2)
        h[k] = v
      end
      h
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
  end

  # @return [Arel::Table]
  def data_attribute_table
    ::DataAttribute.arel_table
  end

  def data_attribute_predicate_id_facet
    return nil if data_attribute_predicate_id.blank?
    referenced_klass.joins(:data_attributes).where(data_attributes: {controlled_vocabulary_term_id: data_attribute_predicate_id})
  end

  def data_attribute_without_predicate_id_facet
    return nil if data_attribute_without_predicate_id.blank?
    not_these = referenced_klass.left_joins(:data_attributes).where(data_attributes: {controlled_vocabulary_term_id: data_attribute_without_predicate_id})

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

    b = data_attribute_table[:value].eq_any(data_attribute_exact_value) if data_attribute_exact_value.present?

    q = referenced_klass.joins(:data_attributes)

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
      v = data_attribute_wildcard_value.collect{|z| wildcard_value(z) } # TODO: should be standardized much earlier on
      a = data_attribute_table[:value].matches_any(v)
    end

    b = data_attribute_table[:value].eq_any(data_attribute_import_exact_value) if data_attribute_import_exact_value.present?

    q = referenced_klass.joins(:data_attributes)

    byebug

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

    referenced_klass.joins(:data_attributes).where(w)
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

    referenced_klass.joins(:data_attributes).where(w)
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

    referenced_klass.joins(:data_attributes).where(w)
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

    referenced_klass.joins(:data_attributes).where(w)
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
      :data_attribute_predicate_id_facet,
      :data_attribute_wildcard_pair_facet,
      :data_attribute_import_wildcard_pair_facet,
      :data_attribute_without_predicate_id_facet,
      :data_attributes_facet,
      :value_facet,
      :import_value_facet
    ]
  end

end
