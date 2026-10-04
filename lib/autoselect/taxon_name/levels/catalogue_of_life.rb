# lib/autoselect/taxon_name/levels/catalogue_of_life.rb
class Autoselect::TaxonName::Levels::CatalogueOfLife < ::Autoselect::Level
  include ::Autoselect::Levels::ColRecordInfo
  include ::Autoselect::Levels::ColRecordLabel

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

end
