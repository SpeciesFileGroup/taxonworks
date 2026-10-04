# lib/autoselect/taxon_name/levels/catalogue_of_life.rb
class Autoselect::TaxonName::Levels::CatalogueOfLife < ::Autoselect::Level
  include ::Autoselect::Levels::ColRecordInfo

  def key
    :catalogue_of_life
  end

  def label
    'Catalogue of Life'
  end

  def description
    'Search the Catalogue of Life for matching names. Returns external ' \
      'results with alignment data for confirmation.'
  end

  def external?
    true
  end

  def record_label(record)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .join(' ')
  end

  def record_label_html(record, term = nil)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .map { |part| ERB::Util.html_escape(part) }
      .join(' ')
  end

  # @param term [String]
  # @param project_id [Integer, nil]
  # @param dataset_id [String, nil] CoL dataset ID from user preferences;
  #   falls back to default when nil
  # @return [Array<OpenStruct>] pseudo-records compatible with TaxonName
  #   autoselect format_results
  def call(
    term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil,
    **_kwargs
  )
    raw = ::Vendor::Colrapi.search(term, dataset_id:)
    results = raw['result'] || []
    return [] if results.empty?

    results.filter_map do |col_result|
      ::Autoselect::TaxonName::ColMatch
        .new(col_result, project_id:, dataset_id:)
        .call
    end
  end

  private

  # The display author+year for a CoL result.
  #
  # CoL renders a recombination's authorship as the original (basionym)
  # author+year wrapped in parens, followed by the combination authorship, e.g.
  # "(Chatton, 1925) Whittaker & Margulis, 1978". Per ICZN convention we show
  # only the original author+year, keeping the parens that signal the
  # recombination. A name described in its original genus has no leading
  # parenthetical and is shown verbatim, e.g. "Linnaeus, 1758".
  #
  # @return [String, nil]
  def col_author_year(record)
    ext = record._col_extension
    return nil unless ext

    authorship = ext[:col_authorship].presence
    return nil unless authorship

    if (leading_parenthetical = authorship[/\A\([^)]*\)/])
      leading_parenthetical
    else
      authorship
    end
  end

end
