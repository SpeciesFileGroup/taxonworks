module Export::Dwca::Checklist
  # Service object for normalizing from occurrence-based CSV to deduplicated
  # taxon-based CSV with OTU UUID taxonIDs and parent/child relationships.
  #
  # Handles:
  # - Extracting unique taxa from occurrence data
  # - Building taxonomic hierarchy from rank columns
  # - Assigning OTU UUID taxonIDs
  # - Creating parentNameUsageID relationships
  # - Handling synonyms in accepted_name_usage_id mode
  class OccurrenceNormalizer
    # @return [Array] of rank strings in hierarchical order (highest to lowest).
    ORDERED_RANKS = Data::ORDERED_RANKS

    # DwC Taxon term column names allowed in the final output row.
    # Derived from the checklist taxon extension definition values (post-header
    # conversion names, e.g. 'class' not 'dwcClass'); anything not listed here
    # (internal bookkeeping, future DwcOccurrence columns, etc.) is
    # automatically excluded at finalization.
    PASSTHROUGH_FIELDS = Data::CHECKLIST_TAXON_EXTENSION_COLUMNS.values.map(&:to_s).freeze

    # DwcOccurrence column names that hold rank-named classification values
    # (as opposed to epithet columns like specificEpithet).
    HIGHER_RANK_COLUMNS = %w[kingdom phylum class order superfamily family subfamily tribe subtribe genus subgenus].freeze

    # Fields written by store_taxon_name_metadata. Cleared for extracted parent
    # taxa (which have no occurrence data of their own) and stripped from all
    # rows during finalization.
    TAXON_NAME_METADATA_FIELDS = %w[
      taxon_name_cached
      taxon_name_cached_is_valid
      taxon_name_cached_valid_taxon_name_id
      taxon_name_gbif_taxonomic_status
    ].freeze

    # @param raw_csv [String] CSV with one row per occurrence
    # @param accepted_name_mode [String] How to handle synonyms
    # @param otu_to_taxon_name_data [Hash] otu_id => { cached:, cached_is_valid:, ... }
    # @param occurrence_to_otu [Hash] "type:id" => otu_id
    def initialize(raw_csv:, accepted_name_mode:, otu_to_taxon_name_data:, occurrence_to_otu:)
      @raw_csv = raw_csv
      @accepted_name_mode = accepted_name_mode
      @otu_to_taxon_name_data = otu_to_taxon_name_data
      @occurrence_to_otu = occurrence_to_otu
    end

    # Main entry point - normalizes taxonomy CSV
    # @return [String, Hash] Normalized CSV and taxon_name_id_to_taxon_id mapping
    def normalize
      parsed = CSV.parse(@raw_csv, headers: true, col_sep: "\t")
      return ["\n", {}] if parsed.empty?

      all_taxa, taxon_name_info = extract_unique_taxa(parsed)

      if @accepted_name_mode == 'accepted_name_usage_id'
        all_taxa = ensure_valid_names_for_synonyms(all_taxa, taxon_name_info)
        all_taxa = fix_synonym_rank_columns(all_taxa, taxon_name_info)
      end

      # Build hierarchy and assign taxonIDs
      processed_taxa, taxon_name_id_to_taxon_id =
        assign_taxon_ids_and_build_hierarchy(all_taxa, taxon_name_info)

      all_taxa = nil # release memory

      processed_taxa = remove_empty_columns(processed_taxa)

      # Collect headers from all rows so taxa with extra columns (e.g. a
      # synonym row that gained infraspecificEpithet from its own hierarchy
      # while the first row never had that key) are not misaligned when written.
      output_headers = processed_taxa.each_with_object([]) do |taxon, headers|
        taxon.each_key { |k| headers << k unless headers.include?(k) }
      end

      csv_output = CSV.generate(col_sep: "\t") do |csv|
        csv << output_headers

        processed_taxa.each do |taxon|
          csv << output_headers.map { |h| taxon[h] }
        end
      end

      [csv_output, taxon_name_id_to_taxon_id]
    end

    private

    attr_reader :raw_csv, :accepted_name_mode, :otu_to_taxon_name_data, :occurrence_to_otu

    # Remove columns that are completely empty across all taxa
    # @param taxa [Array<Hash>] array of taxon hashes
    # @return [Array<Hash>] taxa with empty columns removed
    def remove_empty_columns(taxa)
      return taxa if taxa.empty?

      # Required columns that should never be removed, even if empty
      required_columns = %w[id taxonID scientificName taxonRank].to_set

      # Find which columns have at least one non-empty value
      columns_with_data = Set.new

      taxa.each do |taxon|
        taxon.each do |key, value|
          next if columns_with_data.include?(key)

          if required_columns.include?(key) || value.present?
            columns_with_data << key
          end
        end
      end

      # Filter each taxon to only include columns with data
      taxa.map do |taxon|
        taxon.select { |key, _| columns_with_data.include?(key) }
      end
    end

    # Extract all unique taxa from occurrence data.
    # Uses taxon_name_id as the key to handle homonyms correctly.
    # @param parsed [CSV::Table] parsed occurrence data
    # @return [Array<Hash, Hash>] all_taxa and taxon_name_info hashes
    def extract_unique_taxa(parsed)
      all_taxa = {}
      taxon_name_info = {}
      batch_size = 25_000

      parsed.each_slice(batch_size) do |batch|
        terminal_ids = collect_terminal_ids_for_batch(batch)
        ancestor_lookup = build_ancestor_lookup(terminal_ids)
        merge_taxon_name_info!(taxon_name_info, terminal_ids, ancestor_lookup)

        batch.each do |row|
          process_occurrence_row(row, all_taxa, ancestor_lookup, taxon_name_info)
        end
      end

      [all_taxa, taxon_name_info]
    end

    # Collect unique terminal taxon_name_ids from a batch of occurrence rows.
    # @param batch [Array<CSV::Row>] batch of occurrence rows
    # @return [Array<Integer>] unique terminal taxon_name_ids
    def collect_terminal_ids_for_batch(batch)
      batch.map { |row|
        occurrence_key = "#{row['dwc_occurrence_object_type']}:#{row['dwc_occurrence_object_id']}"

        tn_data = otu_to_taxon_name_data[occurrence_to_otu[occurrence_key]]
        next unless tn_data

        if accepted_name_mode == 'replace_with_accepted_name'
          tn_data[:cached_valid_taxon_name_id] || tn_data[:id]
        else
          tn_data[:id]
        end
      }.compact.uniq
    end

    # Build a lookup hash for ancestor taxon_name_ids from terminal
    # taxon_name_ids.
    # @param terminal_taxon_name_ids [Array<Integer>] IDs of terminal TaxonNames
    # @return [Hash] "terminal_tn_id:rank" => ancestor_tn_id, i.e. gives the
    #   taxon_name id of the ancestor of terminal_tn_id at rank +rank+
    def build_ancestor_lookup(terminal_taxon_name_ids)
      return {} if terminal_taxon_name_ids.empty?

      lookup = {}

      # Query taxon_name_hierarchies WITH join to get rank_class in single query
      hierarchy_relationships = TaxonNameHierarchy
        .joins('JOIN taxon_names ON taxon_names.id = taxon_name_hierarchies.ancestor_id')
        .where(descendant_id: terminal_taxon_name_ids)
        .where.not('ancestor_id = descendant_id') # exclude self-references
        .pluck('taxon_name_hierarchies.descendant_id',
               'taxon_name_hierarchies.ancestor_id',
               'taxon_names.rank_class')

      # Build lookup hash: "terminal_id:rank" => ancestor_id
      hierarchy_relationships.each do |descendant_id, ancestor_id, rank_class|
        next unless rank_class

        rank = rank_class_to_name[rank_class]
        next unless rank

        key = "#{descendant_id}:#{rank}"
        lookup[key] = ancestor_id
      end

      lookup
    end

    # Preload TaxonName metadata needed during normalization and final assembly.
    # @param taxon_name_info [Hash] hash to merge metadata into
    # @param terminal_taxon_name_ids [Array<Integer>]
    # @param ancestor_lookup [Hash]
    def merge_taxon_name_info!(taxon_name_info, terminal_taxon_name_ids, ancestor_lookup)
      ids = (terminal_taxon_name_ids + ancestor_lookup.values).uniq - taxon_name_info.keys
      merge_taxon_name_info_for_ids!(taxon_name_info, ids)
    end

    def merge_taxon_name_info_for_ids!(taxon_name_info, ids)
      ids = ids.uniq - taxon_name_info.keys
      return if ids.empty?

      ids.each_slice(25_000) do |batch|
        ::TaxonName.where(id: batch)
          .pluck(:id, :rank_class, :parent_id, :cached_author_year)
          .each do |id, rank_class, parent_id, cached_author_year|
            rank = rank_class_to_name[rank_class]&.downcase
            taxon_name_info[id] = {
              rank: rank,
              parent_id: parent_id,
              scientific_name_authorship: cached_author_year
            }
          end
      end
    end

    # Cached mapping of rank_class to rank_name.
    # @return [Hash] rank_class string => rank_name string
    def rank_class_to_name
      @rank_class_to_name ||= begin
        mapping = {}

        # Get all NomenclaturalRank classes from all codes
        [
          NomenclaturalRank::Iczn,
          NomenclaturalRank::Icn,
          NomenclaturalRank::Icnp,
          NomenclaturalRank::Icvcn
        ].each do |code_module|
          code_module.ordered_ranks.each do |rank_class|
            mapping[rank_class.name] = rank_class.rank_name
          end
        end

        mapping
      end
    end

    # Process a single occurrence row and extract its taxa.
    # @param row [CSV::Row] occurrence row
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @param ancestor_lookup [Hash] precomputed ancestor lookup
    def process_occurrence_row(row, all_taxa, ancestor_lookup, taxon_name_info = {})
      occurrence_key = "#{row['dwc_occurrence_object_type']}:#{row['dwc_occurrence_object_id']}"

      tn_data = otu_to_taxon_name_data[occurrence_to_otu[occurrence_key]]
      return unless tn_data

      terminal_tn_id = if accepted_name_mode == 'replace_with_accepted_name'
        tn_data[:cached_valid_taxon_name_id] || tn_data[:id]
      else
        tn_data[:id]
      end
      return unless terminal_tn_id

      store_taxon_name_metadata(row, tn_data) if accepted_name_mode == 'accepted_name_usage_id'

      terminal_rank = row['taxonRank']&.downcase
      return unless terminal_rank.present? && row['scientificName'].present?

      add_terminal_taxon(
        row, terminal_tn_id, terminal_rank, all_taxa, ancestor_lookup, taxon_name_info
      )
      extract_ancestor_taxa(
        row, terminal_tn_id, terminal_rank, ancestor_lookup, all_taxa, taxon_name_info
      )
    end

    # Store TaxonName metadata in row for accepted_name_usage_id mode
    # @param row [CSV::Row] occurrence row to modify
    # @param tn_data [Hash] taxon name data
    def store_taxon_name_metadata(row, tn_data)
      return unless tn_data[:cached].present?

      row['taxon_name_cached'] = tn_data[:cached]
      row['taxon_name_cached_is_valid'] = tn_data[:cached_is_valid]
      row['taxon_name_cached_valid_taxon_name_id'] = tn_data[:cached_valid_taxon_name_id]
      row['taxon_name_gbif_taxonomic_status'] = tn_data[:gbif_taxonomic_status]
    end

    # Add terminal taxon to all_taxa if not already present.
    # @param row [CSV::Row] occurrence row
    # @param terminal_tn_id [Integer] terminal taxon_name_id
    # @param terminal_rank [String] rank of terminal taxon
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @param ancestor_lookup [Hash] precomputed ancestor lookup
    def add_terminal_taxon(
      row, terminal_tn_id, terminal_rank, all_taxa, ancestor_lookup, taxon_name_info = {}
    )
      return if all_taxa[terminal_tn_id]

      taxon = row.to_h
      taxon['taxon_name_id'] = terminal_tn_id

      # In accepted_name_usage_id mode, use original name if available.
      if row['taxon_name_cached'].present?
        taxon['scientificName'] = row['taxon_name_cached']
      end

      normalize_occurrence_taxon(
        taxon,
        terminal_rank,
        terminal_rank,
        taxon_name_info: taxon_name_info[terminal_tn_id]
      )

      all_taxa[terminal_tn_id] = taxon

      # Extract parent species for infraspecific taxa.
      if self.class.infraspecific_rank_names.include?(terminal_rank)
        extract_parent_species_for_taxon(
          row, terminal_rank, terminal_tn_id, ancestor_lookup, all_taxa, taxon_name_info
        )
      end
    end

    # Extract parent species for infraspecific taxa.
    # @param row [CSV::Row] the occurrence row
    # @param rank [String] the rank of the infraspecific taxon
    # @param terminal_tn_id [Integer] the taxon_name_id of the infraspecific taxon
    # @param ancestor_lookup [Hash] the ancestor lookup hash
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data (modified in place)
    def extract_parent_species_for_taxon(
      row, rank, terminal_tn_id, ancestor_lookup, all_taxa, taxon_name_info = {}
    )
      genus = row['genus']
      specific_epithet = row['specificEpithet']

      if genus.present? && specific_epithet.present?
        species_tn_id = ancestor_lookup["#{terminal_tn_id}:species"]
        return unless species_tn_id
        return if all_taxa[species_tn_id] # Already extracted

        # Create species taxon
        species_taxon = row.to_h.dup
        species_taxon['taxon_name_id'] = species_tn_id
        species_taxon['scientificName'] = "#{genus} #{specific_epithet}"
        species_taxon['taxonRank'] = 'species'
        normalize_occurrence_taxon(
          species_taxon,
          'species',
          rank,
          taxon_name_info: taxon_name_info[species_tn_id]
        )

        # Clear taxon_name_ metadata since this is an extracted parent.
        TAXON_NAME_METADATA_FIELDS.each { |f| species_taxon[f] = nil }

        all_taxa[species_tn_id] = species_taxon
      end
    end

    # Extract and add ancestor taxa from terminal taxon up to root.
    # @param row [CSV::Row] occurrence row
    # @param terminal_tn_id [Integer] terminal taxon_name_id
    # @param terminal_rank [String] rank of terminal taxon
    # @param ancestor_lookup [Hash] precomputed ancestor lookup
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    def extract_ancestor_taxa(
      row, terminal_tn_id, terminal_rank, ancestor_lookup, all_taxa, taxon_name_info = {}
    )
      # Synonyms have no parentNameUsageID and their hierarchy columns are
      # corrected from their own ancestry in fix_synonym_rank_columns. Skipping
      # here avoids creating ancestor rows with values from the valid name's row.
      return if row['taxon_name_cached_is_valid'] == false

      terminal_rank_index = ORDERED_RANKS.index(terminal_rank)
      return unless terminal_rank_index && terminal_rank_index > 0

      (0...terminal_rank_index).reverse_each do |i|
        higher_rank = ORDERED_RANKS[i]
        rank_taxon_name = row[higher_rank]
        next if rank_taxon_name.blank?

        ancestor_tn_id = ancestor_lookup["#{terminal_tn_id}:#{higher_rank}"]
        next unless ancestor_tn_id

        # Early termination: if this ancestor already exists, all higher ones do too.
        break if all_taxa[ancestor_tn_id]

        ancestor_taxon = row.to_h.dup
        ancestor_taxon['taxon_name_id'] = ancestor_tn_id
        ancestor_taxon['scientificName'] = rank_taxon_name
        ancestor_taxon['taxonRank'] = higher_rank
        normalize_occurrence_taxon(
          ancestor_taxon,
          higher_rank,
          terminal_rank,
          taxon_name_info: taxon_name_info[ancestor_tn_id]
        )

        # Clear taxon_name_ metadata for extracted ancestors.
        TAXON_NAME_METADATA_FIELDS.each { |f| ancestor_taxon[f] = nil }

        all_taxa[ancestor_tn_id] = ancestor_taxon
      end
    end

    # Overwrite rank and classification columns for synonym rows using the
    # synonym's own taxon_name_hierarchies ancestry, not the valid name's.
    # DwcOccurrence stores the valid name's classification (via current_valid_taxon_name),
    # so synonym rows otherwise inherit the wrong genus, family, taxonRank, etc.
    #
    # All hierarchy columns (genus through kingdom, higherClassification) are
    # corrected from the synonym's own ancestry — useful for understanding the
    # historical classification the synonym was published under. parentNameUsageID
    # is left empty for synonyms (handled in build_final_taxon), since synonyms
    # do not participate in tree navigation.
    #
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @return [Hash] updated all_taxa
    def fix_synonym_rank_columns(all_taxa, taxon_name_info = {})
      synonym_tn_ids = all_taxa.each_value.filter_map { |taxon|
        taxon['taxon_name_id'] if taxon['taxon_name_cached_is_valid'] == false
      }
      return all_taxa if synonym_tn_ids.empty?

      # Query ancestors including self (self gives epithet and own rank).
      synonym_ancestors = Hash.new { |h, k| h[k] = {} }
      TaxonNameHierarchy
        .joins('JOIN taxon_names ON taxon_names.id = taxon_name_hierarchies.ancestor_id')
        .where(descendant_id: synonym_tn_ids)
        .pluck('taxon_name_hierarchies.descendant_id', 'taxon_names.rank_class', 'taxon_names.name')
        .each do |descendant_id, rank_class, name|
          rank = rank_class_to_name[rank_class]
          next unless rank
          synonym_ancestors[descendant_id][rank] = name
        end

      infraspecific_ranks = self.class.infraspecific_rank_names.to_set

      all_taxa.each_value do |taxon|
        next unless taxon['taxon_name_cached_is_valid'] == false
        ancestors = synonym_ancestors[taxon['taxon_name_id']]
        next if ancestors.empty?

        # Overwrite all rank columns from synonym's own hierarchy.
        HIGHER_RANK_COLUMNS.each { |col| taxon[col] = ancestors[col] }
        taxon['specificEpithet'] = ancestors['species']

        synonym_rank = (ORDERED_RANKS & ancestors.keys).last
        taxon['taxonRank'] = synonym_rank if synonym_rank
        taxon['infraspecificEpithet'] = infraspecific_ranks.include?(synonym_rank) ? ancestors[synonym_rank] : nil
        normalize_accepted_name_usage_taxon(
          taxon,
          taxon_name_info: taxon_name_info[taxon['taxon_name_id']]
        )
      end

      all_taxa
    end

    # Ensure valid names exist for all synonyms.
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @return [Hash] updated all_taxa with valid names added
    def ensure_valid_names_for_synonyms(all_taxa, taxon_name_info = {})
      # Build lookup of missing valid names => a synonym template.
      valid_id_to_synonym = {}
      all_taxa.each_value do |taxon|
        next unless taxon['taxon_name_cached_is_valid'] == false
        valid_id = taxon['taxon_name_cached_valid_taxon_name_id']
        next unless valid_id.present? && !all_taxa[valid_id]
        # Yes, we're just picking out any one synonym here (cf. below):
        valid_id_to_synonym[valid_id] ||= taxon
      end

      return all_taxa if valid_id_to_synonym.empty?

      valid_ids = valid_id_to_synonym.keys
      valid_ancestor_lookup = build_ancestor_lookup(valid_ids)
      merge_taxon_name_info!(taxon_name_info, valid_ids, valid_ancestor_lookup)

      ::TaxonName.where(id: valid_ids).each do |valid_tn|
        rank = valid_tn.rank&.downcase
        next unless rank

        template_taxon = valid_id_to_synonym[valid_tn.id]
        next unless template_taxon

        # The template's rank columns (genus, family, higherClassification, etc.)
        # already reflect the valid name's classification, not the synonym's -
        # this is why it didn't matter *which* synonym of the valid name we
        # selected above.
        valid_taxon = template_taxon.dup
        valid_taxon['taxon_name_id'] = valid_tn.id
        valid_taxon['scientificName'] = valid_tn.cached
        valid_taxon['taxonRank'] = rank
        valid_taxon['taxon_name_cached'] = valid_tn.cached
        valid_taxon['taxon_name_cached_is_valid'] = true
        valid_taxon['taxon_name_cached_valid_taxon_name_id'] = valid_tn.id

        taxon_name_info[valid_tn.id] = {
          rank: rank,
          parent_id: valid_tn.parent_id,
          scientific_name_authorship: valid_tn.cached_author_year
        }

        normalize_accepted_name_usage_taxon(
          valid_taxon,
          rank,
          template_taxon['taxonRank']&.downcase,
          taxon_name_info: taxon_name_info[valid_tn.id]
        )

        all_taxa[valid_tn.id] = valid_taxon
        extract_accepted_name_usage_ancestor_taxa(
          valid_taxon,
          valid_tn.id,
          rank,
          valid_ancestor_lookup,
          all_taxa,
          taxon_name_info
        )
      end

      all_taxa
    end

    # Assign OTU UUID taxonIDs and parentNameUsageIDs to all taxa.
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id:, scientific_name_authorship: }
    # @return [Array] [processed_taxa, taxon_name_id_to_taxon_id]
    def assign_taxon_ids_and_build_hierarchy(all_taxa, taxon_name_info)
      taxa_with_ids, taxon_name_id_to_taxon_id =
        assign_taxon_uuids(all_taxa, taxon_name_info)
      processed_taxa = build_processed_taxa(
        taxa_with_ids, taxon_name_info, taxon_name_id_to_taxon_id
      )

      [processed_taxa, taxon_name_id_to_taxon_id]
    end

    # Assign OTU UUID taxonIDs to all taxa, grouped by rank.
    # Taxa without an OTU UUID identifier are excluded from the export.
    # @param all_taxa [Hash] taxon_name_id => taxon data
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id: }
    # @return [Array] [taxa_with_ids, taxon_name_id_to_taxon_id mapping]
    def assign_taxon_uuids(all_taxa, taxon_name_info)
      uuid_map = taxon_name_id_to_otu_uuid(all_taxa.keys)
      taxon_name_id_to_taxon_id = {}
      taxa_with_ids = []

      # Orderings here determine the final CSV row ordering.
      ORDERED_RANKS.each do |rank|
        rank_taxa = all_taxa.select { |tn_id, taxon|
          taxon_name_info[tn_id]&.[](:rank) == rank
        }.sort_by { |tn_id, taxon| taxon['scientificName'] || '' }

        rank_taxa.each do |tn_id, taxon|
          next if taxon_name_id_to_taxon_id[tn_id]

          uuid = uuid_map[tn_id]
          next unless uuid

          taxon_name_id_to_taxon_id[tn_id] = uuid

          taxa_with_ids << {
            taxon: taxon, taxon_id: uuid, taxon_name_id: tn_id, rank: rank
          }
        end
      end

      [taxa_with_ids, taxon_name_id_to_taxon_id]
    end

    # Build a mapping of taxon_name_id => OTU UUID for the given taxon_name_ids.
    # Only includes taxa that have an OTU with a Uuid identifier.
    # @param taxon_name_ids [Array<Integer>]
    # @return [Hash] taxon_name_id => uuid string
    def taxon_name_id_to_otu_uuid(taxon_name_ids)
      return {} if taxon_name_ids.empty?

      taxon_name_ids.each_slice(25_000).each_with_object({}) do |batch, result|
        ::Otu
          .joins("JOIN identifiers ON identifiers.identifier_object_id = otus.id
                    AND identifiers.identifier_object_type = 'Otu'
                    AND identifiers.type LIKE 'Identifier::Global::Uuid%'
                    AND identifiers.position = 1")
          .where(taxon_name_id: batch)
          .pluck('otus.taxon_name_id', 'identifiers.cached')
          .each { |tn_id, uuid| result[tn_id] = uuid }
      end
    end

    # Build final processed taxa with parent/accepted relationships.
    # @param taxa_with_ids [Array<Hash>] taxa with assigned IDs
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id: }
    # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => taxonID
    # @return [Array<Hash>] processed taxa ready for export
    def build_processed_taxa(
      taxa_with_ids, taxon_name_info, taxon_name_id_to_taxon_id
    )
      taxa_with_ids.filter_map do |item|
        build_final_taxon(
          item[:taxon],
          item[:taxon_id],
          item[:taxon_name_id],
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )
      end
    end

    # Build a single processed taxon with all relationships.
    # @param taxon [Hash] source taxon data
    # @param taxon_id [Integer] assigned taxonID
    # @param taxon_name_id [Integer] source taxon_name_id
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id: }
    # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => taxonID
    # @return [Hash] processed taxon
    def build_final_taxon(
      taxon, taxon_id, taxon_name_id, taxon_name_info, taxon_name_id_to_taxon_id
    )
      if accepted_name_mode == 'accepted_name_usage_id'
        accepted_name_usage_id, taxonomic_status = determine_accepted_name_usage(
          taxon,
          taxon_id,
          taxon_name_id_to_taxon_id
        )
      end

      # GBIF checklist guidance requires acceptedNameUsageID on synonym rows to
      # point at an existing record in the dataset. If the accepted name could
      # not be included in this export, omit the synonym row instead of
      # emitting an invalid reference.
      if accepted_name_mode == 'accepted_name_usage_id' &&
         taxonomic_status.present? &&
         taxonomic_status != 'accepted' &&
         accepted_name_usage_id.nil?
        return nil
      end

      parent_id = nil
      # Synonyms don't participate in parent hierarchy.
      if accepted_name_mode == 'replace_with_accepted_name' ||
         taxonomic_status == 'accepted'
        # Find parent via TaxonName parent_id, walking up hierarchy if needed.
        current_parent_id = taxon_name_info[taxon_name_id]&.[](:parent_id)

        while current_parent_id
          # Check if this parent is in the export
          if taxon_name_id_to_taxon_id[current_parent_id]
            parent_id = taxon_name_id_to_taxon_id[current_parent_id]
            break
          end

          # Parent not in export, walk up to its parent
          current_parent_id = taxon_name_info[current_parent_id]&.[](:parent_id)
        end
      end

      processed_taxon = {
        'id' => taxon_id,
        'taxonID' => taxon_id,
        'parentNameUsageID' => parent_id
      }

      if accepted_name_mode == 'accepted_name_usage_id'
        processed_taxon['acceptedNameUsageID'] = accepted_name_usage_id
        processed_taxon['taxonomicStatus'] = taxonomic_status
      end

      # keep processed_taxon value during the merge when both processed_taxon
      # and taxon have a value for a key.
      processed_taxon.merge(taxon.slice(*PASSTHROUGH_FIELDS)) { |_key, processed_taxon_value, _taxon_value| processed_taxon_value }
    end

    def populate_normalized_taxon_fields(taxon, taxon_name_info = nil)
      taxon['scientificNameAuthorship'] = taxon_name_info&.[](:scientific_name_authorship)
      # The original higherClassification may include more ranks than the
      # checklist does, so just always recompute it.
      taxon['higherClassification'] = recompute_higher_classification(taxon)
    end

    def recompute_higher_classification(taxon)
      rank = taxon['taxonRank']&.downcase
      rank_index = ORDERED_RANKS.index(rank)
      return taxon['higherClassification'] unless rank_index

      classification_parts = ORDERED_RANKS[0...rank_index]
        .filter_map { |r| HIGHER_RANK_COLUMNS.include?(r) ? taxon[r].presence : nil }

      classification_parts.empty? ? nil : classification_parts.join(Export::Dwca::DELIMITER)
    end

    # Determine acceptedNameUsageID and taxonomicStatus for a taxon.
    # @param taxon [Hash] taxon data
    # @param taxon_id [Integer] assigned taxonID
    # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => taxonID
    # @return [Array] [acceptedNameUsageID, taxonomicStatus]
    def determine_accepted_name_usage(
      taxon, taxon_id, taxon_name_id_to_taxon_id
    )
      return [nil, nil] unless accepted_name_mode == 'accepted_name_usage_id'

      is_valid = taxon['taxon_name_cached_is_valid']

      if !is_valid.nil?
        return [taxon_id, 'accepted'] if is_valid == true

        # This taxon is marked as invalid (synonym).
        valid_taxon_name_id = taxon['taxon_name_cached_valid_taxon_name_id']
        if valid_taxon_name_id.present?
          accepted_id = taxon_name_id_to_taxon_id[valid_taxon_name_id]
          # NOTE: accepted_id may be nil when the valid name has no OTU UUID
          # in this export - technically this is bad DwC checklist behavior:
          # https://ipt.gbif.org/manual/en/ipt/latest/best-practices-checklists#publishing-synonymy
          # "An dwc:acceptedNameUsageID must point to an existing record in
          # the dataset"
          status = taxon['taxon_name_gbif_taxonomic_status'] || 'synonym'
          [accepted_id, status]
        else
          [nil, nil]
        end
      else
        # No validity data - this is an extracted higher taxon from rank columns.
        [taxon_id, 'accepted']
      end
    end

    # Mutates an occurrence-derived taxon row in place by:
    # - clearing rank columns below current_rank
    # - clearing taxon-specific fields not applicable to the extracted rank
    # - recomputing normalized fields from the taxon's own metadata
    #
    # It preserves all other fields as-is. In particular, it does not rewrite
    # row identity fields such as taxonRank or scientificName; callers are
    # expected to set those.
    # @param taxon [Hash] the taxon data hash to modify
    # @param current_rank [String] the rank being extracted
    # @param original_rank [String] the original taxonRank before extraction
    def normalize_occurrence_taxon(
      taxon, current_rank, original_rank = nil, taxon_name_info: nil
    )
      normalize_taxon_for_rank_transition(
        taxon,
        current_rank,
        original_rank,
        taxon_name_info: taxon_name_info
      )
    end

    def normalize_accepted_name_usage_taxon(
      taxon, current_rank = nil, original_rank = nil, taxon_name_info: nil
    )
      current_rank ||= taxon['taxonRank']&.downcase
      original_rank ||= current_rank
      normalize_taxon_for_rank_transition(
        taxon,
        current_rank,
        original_rank,
        taxon_name_info: taxon_name_info
      )
    end

    def normalize_taxon_for_rank_transition(
      taxon, current_rank, original_rank = nil, taxon_name_info: nil
    )
      current_id = ORDERED_RANKS.index(current_rank)
      return unless current_id

      if current_rank == original_rank
        populate_normalized_taxon_fields(taxon, taxon_name_info)
        return
      end

      # Clear lower rank columns
      ORDERED_RANKS[(current_id + 1)..-1].each do |lower_rank|
        taxon[lower_rank] = nil
      end

      # Fields to keep for extracted taxa
      rank_columns = ORDERED_RANKS.map(&:to_s)
      fields_to_keep =
        rank_columns + ['scientificName', 'taxonRank', 'nomenclaturalCode']

      # Add epithet fields based on rank
      if current_rank == 'species'
        fields_to_keep << 'specificEpithet'
      elsif self.class.infraspecific_rank_names.include?(current_rank)
        fields_to_keep << 'specificEpithet'
        fields_to_keep << 'infraspecificEpithet'
      end

      # Clear all other taxon-specific fields
      Data::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys.each do |field|
        field_str = field.to_s
        field_str = 'class' if field == :dwcClass
        taxon[field_str] = nil unless fields_to_keep.include?(field_str)
      end

      populate_normalized_taxon_fields(taxon, taxon_name_info)
    end

    def extract_accepted_name_usage_ancestor_taxa(
      row, terminal_tn_id, terminal_rank, ancestor_lookup, all_taxa, taxon_name_info = {}
    )
      terminal_rank_index = ORDERED_RANKS.index(terminal_rank)
      return unless terminal_rank_index && terminal_rank_index > 0

      (0...terminal_rank_index).reverse_each do |i|
        higher_rank = ORDERED_RANKS[i]
        rank_taxon_name = row[higher_rank]
        next if rank_taxon_name.blank?

        ancestor_tn_id = ancestor_lookup["#{terminal_tn_id}:#{higher_rank}"]
        next unless ancestor_tn_id

        # All higher ancestors are in all_taxa if this one is.
        break if all_taxa[ancestor_tn_id]

        ancestor_taxon = row.to_h.dup
        ancestor_taxon['taxon_name_id'] = ancestor_tn_id
        ancestor_taxon['scientificName'] = rank_taxon_name
        ancestor_taxon['taxonRank'] = higher_rank
        normalize_accepted_name_usage_taxon(
          ancestor_taxon,
          higher_rank,
          terminal_rank,
          taxon_name_info: taxon_name_info[ancestor_tn_id]
        )

        TAXON_NAME_METADATA_FIELDS.each { |f| ancestor_taxon[f] = nil }

        all_taxa[ancestor_tn_id] = ancestor_taxon
      end
    end

    # Get all infraspecific rank names
    def self.infraspecific_rank_names
      @infraspecific_rank_names ||= begin
        [
          ::NomenclaturalRank::Iczn::SpeciesGroup,
          ::NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup,
          ::NomenclaturalRank::Icnp::SpeciesGroup
        ].flat_map { |group|
          ranks = group.ordered_ranks.map(&:rank_name)
          species_idx = ranks.index('species')
          species_idx ? ranks[(species_idx + 1)..] : []
        }.uniq
      end
    end
  end
end
