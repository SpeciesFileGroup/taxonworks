# Helpers and facets for queries that reference Citations.
#
module Queries::Concerns::Citations

  extend ActiveSupport::Concern

  def self.params
    [
      :citations,
      :citation_documents,
      :origin_citation
    ]
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

    # @params citation_documents [ture, false]
    # @return [Boolean, nil]
    #   true - has citations, sources have documents
    #   false - has citations, sources do not have documents
    #   nil - ignored
    attr_accessor :citation_documents
  end

  def set_citations_params(params)
    @citation_documents = boolean_param(params, :citation_documents)
    @citations = boolean_param(params, :citations)
    @origin_citation = boolean_param(params, :origin_citation)

    # All params are Hash here
    @source_query = ::Queries::Source::Filter.new(params[:source_query]) if params[:source_query]
  end

  # @return [Arel::Table]
  def citation_table
    ::Citation.arel_table
  end

  def citation_documents_facet
    return nil if citation_documents.nil?
    if citation_documents
      referenced_klass.joins(citations: [:documents])
    else
      referenced_klass.left_joins(citations: [source: [:documents]]).where('sources.id IS NOT null and documents.id is NULL')
    end
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

  def self.merge_clauses
    [
      :citation_documents_facet,
      :citations_facet,
      :origin_citation_facet,
      :source_query_facet,
    ]
  end

end
