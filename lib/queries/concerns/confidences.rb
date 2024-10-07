# Query on confidence attributes
#
# For filter queries:
# !! requires `set_confidences_params` be called in initialize()
#
# Tested on spec/lib/queries/otu/filter_spec.rb
module Queries::Concerns::Confidences
  include Queries::Helpers

  def self.params
    [
      :confidences,
      :without_confidence_level_id,
      :confidence_level_id, 
      confidence_level_id: [],
      without_confidence_level_id: []
    ]
  end

  extend ActiveSupport::Concern

  included do

    # @param confidence_level_id [Int, Array]
    #   objects matching one or more confidence levels
    attr_accessor :confidence_level_id

    # @param confidences_without_confidence_level_id [Integer, String, Array] of ConfidenceLevel (CVT) ids
    # @return Array
    #  match any record that does not have a data attribute with this predicate_id
    attr_accessor :without_confidence_level_id

    # @return [True, False, nil]
    #   true - has a Confidence 
    #   false - does not have a Confidence 
    #   nil - not applied
    attr_accessor :confidences

    def confidence_level_id
      [@confidence_level_id].flatten.compact
    end

    def without_confidence_level_id
      [@without_confidence_level_id].flatten.compact
    end
  end

  def set_confidences_params(params)
    @confidence_level_id = params[:confidence_level_id]
    @without_confidence_level_id = params[:without_confidence_level_id]
    @confidences = boolean_param(params, :confidences)
  end

  # @return [Arel::Table]
  def confidence_table
    ::Confidence.arel_table
  end

  def confidence_level_id_facet
    return nil if confidence_level_id.empty?
    referenced_klass.joins(:confidences).where(confidences: {confidence_level_id: confidence_level_id})
  end

  def without_confidence_level_id_facet
    return nil if without_confidence_level_id.empty?
    not_these = referenced_klass.left_joins(:confidences).where(confidences: {confidence_level_id: without_confidence_level_id})

    s = referenced_klass.with(not_these:)
      .joins("LEFT JOIN not_these AS not_these1 ON not_these1.id = #{table.name}.id")
      .where('not_these1.id IS NULL').to_sql

    referenced_klass.from("(#{s}) as #{table.name}")
  end

  def confidences_facet
    return nil if confidences.nil?
    if confidences
      referenced_klass.joins(:confidences).distinct
    else
      referenced_klass.where.missing(:confidences)
    end
  end

  def self.merge_clauses
    [
      :confidences_facet,
      :without_confidence_level_id_facet,
      :confidence_level_id_facet,
    ]
  end

end
