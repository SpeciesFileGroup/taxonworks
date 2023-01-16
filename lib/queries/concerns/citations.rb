# Helpers and facets for queries that reference Citations.
#
module Queries::Concerns::Citations

  extend ActiveSupport::Concern

  def self.permit(params)
    params.permit(
      :citations,
      :origin_citation
    )
  end

  included do
    # @params citations [String]
    # @return [Boolean]
    #  nil - with/out Citations
    #  true - with Citations
    #  false - without Citations
    attr_accessor :citations

    # @params citations [String]
    # @return [Boolean]
    #  nil - with/out Origin Citation
    #  true - with Origin Citation
    #  false - without Origin Citations
    attr_accessor :origin_citation

    # @return [::Query::Source::Filter, nil]
    attr_accessor :source_query
  end

  def set_citations_params(params)
    @citations = boolean_param(params, :citations)
    @origin_citation = boolean_param(params, :origin_citation)

    # All params are Hash here
    @source_query = ::Queries::Source::Filter.new(params[:source_query]) if params[:source_query]
  end

  # @return [Arel::Table]
  def citation_table 
    ::Citation.arel_table
  end

  def self.merge_clauses
    [ :citations_facet,
      :origin_citation_facet,
      # Do not include source_query_facet here
    ]
  end

  def citations_facet
    return nil if citations.nil?

    if citations
      referenced_klass.joins(:citations)
    else
      referenced_klass.where.missing(:citations)
    end
  end

  def origin_citation_facet
    return nil if origin_citation.nil?

    if origin_citation
      referenced_klass.joins(:origin_citation)
    else
      referenced_klass.where.missing(:origin_citation)
    end
  end

  def source_query_facet
    return nil if source_query.nil?
    s = 'WITH query_sources AS (' + source_query.all.to_sql + ')' 

    s << ' ' + referenced_klass
    .joins(:citations)
    .joins('JOIN query_sources as query_sources1 on citations.source_id = query_sources1.id')
    .to_sql

    referenced_klass.from('(' + s + ') as ' + referenced_klass.name.tableize) 
  end

end