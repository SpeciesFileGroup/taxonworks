# Helpers and facets for queries that reference Tags.
#
# Test coverage is currently in spec/lib/queries/source/filter_spec.rb.
#
# You must define
#
#    def table
#      :;Model.arel_table
#    end
#
# in including modules.
#
module Queries::Concerns::Citations

  extend ActiveSupport::Concern

  included do

    # @params citations [String]
    #  'without_citations' - names without citations
    #  'without_origin_citation' - names without an origin citation
    attr_accessor :citations

    # Params from Queries::Source::Filter
    attr_accessor :source_query
  end

  def set_citations_params(params)
    @citations = params[:citations]

    # TODO: write source_params
    @source_query = Queries::Source::Filter.new(
      params.select{|a,b| source_params.include?(a.to_s) }
    )
  end

  # @return [Arel::Table]
  def citation_table 
    ::Citation.arel_table
  end

  # @return Scope
  def citations_facet
    return nil if citations.nil?

    n = table.name
    k = "::#{n}".classify.safe_constantize

    citation_conditions = ::Citation.arel_table[:citation_object_id].eq(k.arel_table[:id]).and(
      ::Citation.arel_table[:citation_object_type].eq(n))

    if citations == 'without_origin_citation'
      citation_conditions = citation_conditions.and(::Citation.arel_table[:is_original].eq(true))
    end

    k.where.not(::Citation.where(citation_conditions).arel.exists)
  end


end
