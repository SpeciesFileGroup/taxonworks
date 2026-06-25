# Data gathering and report assembly for the Type material dashboard.
#
# Queries (ActiveRecord) live here; the pure aggregations are delegated to
# Utilities::TypeMaterial::Summary and Utilities::DarwinCore::TypeMaterialSummary.
#
# @author Claude (>50% of code)
#
module Tasks::TypeMaterials::DashboardHelper

  # Cap on the number of TypeMaterial rows shipped to the client-side table.
  # Chart aggregations are computed over the full (uncapped) set.
  MAX_TABLE_ROWS = 10_000

  UNSPECIFIED = Utilities::TypeMaterial::Summary::UNSPECIFIED

  # Assemble the full dashboard report for a scoped TaxonName query.
  #
  # @param taxon_name_query [Queries::TaxonName::Filter]
  # @param project_id [Integer]
  # @return [Hash]
  def type_material_dashboard_report(taxon_name_query, project_id)
    protonym_ids = taxon_name_query.all.unscope(:select).select(:id)

    date_counts = taxon_name_coverage_data(protonym_ids, project_id)
    rows = type_material_aggregate_rows(protonym_ids, project_id)
    type_types = rows.map { |row| row[:type_type] }.uniq.sort

    dwc_rows = rows.map { |row| row[:dwc] }
    distinct_collection_object_dwc = rows
      .uniq { |row| row[:collection_object_id] }
      .map { |row| row[:dwc] }

    {
      filter_params: taxon_name_query.params,
      taxon_name_coverage: Utilities::TypeMaterial::Summary.coverage_totals(date_counts),
      decades: Utilities::TypeMaterial::Summary.decade_windows(date_counts),
      type_type_counts: Utilities::TypeMaterial::Summary.counts(rows.map { |row| row[:type_type] }),
      sex_counts: Utilities::DarwinCore::TypeMaterialSummary.sex_counts(dwc_rows),
      georeference: Utilities::DarwinCore::TypeMaterialSummary.georeference_partition(distinct_collection_object_dwc),
      repository_by_type: Utilities::TypeMaterial::Summary.stacked(repository_entries(rows), stacks: type_types),
      country_by_type: Utilities::TypeMaterial::Summary.stacked(country_entries(rows), stacks: type_types),
      table: type_material_table(protonym_ids, project_id, type_types),
      meta: {
        total_type_materials: rows.size,
        table_truncated: rows.size > MAX_TABLE_ROWS
      }
    }
  end

  # Per scoped protonym: its nomenclature date and TypeMaterial count.
  #
  # @return [Array<Array(Date, Integer)>]
  def taxon_name_coverage_data(protonym_ids, project_id)
    ::TaxonName
      .where(id: protonym_ids)
      .joins(
        'LEFT JOIN type_materials tm_cov ON tm_cov.protonym_id = taxon_names.id ' \
        "AND tm_cov.project_id = #{project_id.to_i}"
      )
      .group('taxon_names.id', 'taxon_names.cached_nomenclature_date')
      .pluck('taxon_names.cached_nomenclature_date', Arel.sql('COUNT(tm_cov.id)'))
  end

  # Lightweight Hash per TypeMaterial record (whole set, no cap) carrying just
  # the fields needed to aggregate every chart.
  #
  # @return [Array<Hash>]
  def type_material_aggregate_rows(protonym_ids, project_id)
    type_material_base_scope(protonym_ids, project_id)
      .pluck(
        'type_materials.type_type',
        'co.id',
        'co.total',
        'r.acronym',
        Arel.sql('dwc."sex"'),
        Arel.sql('dwc."country"'),
        Arel.sql('dwc."decimalLatitude"'),
        Arel.sql('dwc."decimalLongitude"')
      )
      .map do |type_type, collection_object_id, total, repository_acronym, sex, country, latitude, longitude|
        {
          type_type:,
          collection_object_id:,
          individuals: total.nil? ? 1 : total.to_i,
          repository_acronym: repository_acronym.presence || UNSPECIFIED,
          dwc: {
            'sex' => sex,
            'country' => country,
            'decimalLatitude' => latitude,
            'decimalLongitude' => longitude
          }
        }
      end
  end

  # The TypeMaterial scope joined to CollectionObject, Repository, Protonym and
  # DwcOccurrence, shared by chart and table queries.
  #
  # @return [ActiveRecord::Relation]
  def type_material_base_scope(protonym_ids, project_id)
    ::TypeMaterial
      .where(project_id:)
      .where(protonym_id: protonym_ids)
      .joins('JOIN collection_objects co ON co.id = type_materials.collection_object_id')
      .joins('JOIN taxon_names tn ON tn.id = type_materials.protonym_id')
      .joins('LEFT JOIN repositories r ON r.id = co.repository_id')
      .joins(
        'LEFT JOIN dwc_occurrences dwc ON dwc.dwc_occurrence_object_id = co.id ' \
        "AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND dwc.project_id = #{project_id.to_i}"
      )
  end

  # [category, stack, value] triples for the per-repository stacked chart.
  #
  # @return [Array<Array>]
  def repository_entries(rows)
    rows.map { |row| [row[:repository_acronym], row[:type_type], row[:individuals]] }
  end

  # [category, stack, value] triples for the per-country stacked chart.
  #
  # @return [Array<Array>]
  def country_entries(rows)
    rows.map do |row|
      country = row[:dwc]['country']
      label = country.to_s.strip.empty? ? UNSPECIFIED : country.to_s
      [label, row[:type_type], row[:individuals]]
    end
  end

  # The (capped, ordered) TypeMaterial rows for the client-side table. Each row
  # pivots its individual count into the column for its type_type.
  #
  # @param type_types [Array<String>] complete set of type_type columns
  # @return [Hash] { type_types:, rows: }
  def type_material_table(protonym_ids, project_id, type_types)
    gid_prefix = "gid://#{GlobalID.app}"
    source_id_sql = Arel.sql(
      '(SELECT cit.source_id FROM citations cit ' \
      "WHERE cit.citation_object_id = tn.id AND cit.citation_object_type = 'TaxonName' " \
      'AND cit.is_original IS TRUE LIMIT 1)'
    )

    table_rows = type_material_base_scope(protonym_ids, project_id)
      .order('tn.cached_original_combination ASC NULLS LAST', 'type_materials.id ASC')
      .limit(MAX_TABLE_ROWS)
      .pluck(
        'type_materials.id',
        'type_materials.type_type',
        'co.id',
        'co.total',
        'tn.id',
        'tn.cached_original_combination',
        'tn.cached_author',
        Arel.sql('EXTRACT(YEAR FROM tn.cached_nomenclature_date)::integer'),
        'r.acronym',
        source_id_sql
      )
      .map do |type_material_id, type_type, collection_object_id, total, taxon_name_id,
               cached_original_combination, cached_author, year,
               repository_acronym, source_id|
        {
          type_material_id:,
          taxon_name_id:,
          taxon_name_global_id: "#{gid_prefix}/TaxonName/#{taxon_name_id}",
          collection_object_id:,
          collection_object_global_id: "#{gid_prefix}/CollectionObject/#{collection_object_id}",
          cached_original_combination:,
          cached_author:,
          year:,
          repository_acronym: repository_acronym.presence,
          source_id:,
          individuals_by_type: { type_type => (total.nil? ? 1 : total.to_i) }
        }
      end

    { type_types:, rows: table_rows }
  end

end
