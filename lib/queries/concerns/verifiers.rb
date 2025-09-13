# Helpers and facets for queries that reference Verifiers.
#
module Queries::Concerns::Verifiers

  extend ActiveSupport::Concern

  def self.params
    [
      :verifiers,
    ]
  end

  included do
    # @params verifiers [String]
    # @return [Boolean]
    #  nil - with/out
    #  true - with verifiers
    #  false - without verifiers
    attr_accessor :verifiers
  end

  def set_verifiers_params(params)
    @verifiers = boolean_param(params, :verifiers)
  end

  # @return [Arel::Table]
  def verifier_table
    ::Verifier.arel_table
  end

  def verifiers_facet
    return nil if verifiers.nil?

    if verifiers
      referenced_klass.joins(:verifiers).distinct
    else
      referenced_klass.where.missing(:verifiers)
    end
  end

  def self.merge_clauses
    [
      :verifiers_facet,
    ]
  end

end
