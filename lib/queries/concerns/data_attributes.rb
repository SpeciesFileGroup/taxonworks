# Linking DataAttribute to  queries that reference DataAttributes
#
# For filter queries:
# !! requires a `base_query` method ?! ... or not
# !! requires `set_data_attributes_params` be called in initialize()
#
# See spec/lib/queries/collection_object/filter_spec.rb for existing spec tests
#
module Queries::Concerns::DataAttributes
  include Queries::Helpers

  def self.params
   [   
      :data_attribute_exact_value,
      :data_attribute_predicate_id,
      :data_attribute_value,
      :data_attributes,
      data_attribute_predicate_id: [],
      data_attribute_value: [],
    ]
  end

  extend ActiveSupport::Concern

  included do
    # @param data_attribute_predicate_id [Integer, String, Array] of Predicate (CVT) ids
    # @return Array
    attr_accessor :data_attribute_predicate_id

    # @param data_attribute_value[String, Array] of values
    # @return Array
    attr_accessor :data_attribute_value

    # @return Boolean
    #   wether or not to match on exact value
    attr_accessor :data_attribute_exact_value

    # @return [True, False, nil]
    #   true - has a data_attribute
    #   false - does not have a data_attribute
    #   nil - not applied
    attr_accessor :data_attributes

    def data_attribute_predicate_id
      [@data_attribute_predicate_id].flatten.compact
    end

    def data_attribute_value
      [@data_attribute_value].flatten.compact.select{|a| a.present?}
    end
  end

  def set_data_attributes_params(params)
    @data_attribute_predicate_id = params[:data_attribute_predicate_id]
    @data_attribute_value = params[:data_attribute_value]
    @data_attribute_exact_value = boolean_param(params, :data_attribute_exact_value)
    @data_attributes = boolean_param(params, :data_attributes)
  end

  # @return [Arel::Table]
  def data_attribute_table
    ::DataAttribute.arel_table
  end

  def self.merge_clauses
    [
     :data_attribute_predicate_facet,
     :data_attribute_value_facet,
     :data_attributes_facet,
    ]
  end

  def data_attributes_facet
    return nil if data_attributes.nil?
    if data_attributes
      base_query.joins(:data_attributes).distinct
    else
      base_query.left_outer_joins(:data_attributes)
        .where(data_attributes: {id: nil})
        .distinct
    end
  end

  def data_attribute_predicate_facet
    return nil if data_attribute_predicate_id.empty?
    q = base_query.joins(:data_attributes)
    q.where(data_attribute_table[:controlled_vocabulary_term_id].eq_any(data_attribute_predicate_id))
  end

  # Exact
  def data_attribute_value_facet
    return nil if data_attribute_value.empty?
    q = base_query.joins(:data_attributes)
    if data_attribute_exact_value
      q.where(data_attribute_table[:value].eq_any(data_attribute_value))
    else
      # TODO: standardize defn' of exact
      v = self.data_attribute_value.collect{|a| '%' + a.to_s.strip.gsub(/\s+/, '%') + '%' }
      q.where(data_attribute_table[:value].matches_any(v))
    end
  end

end