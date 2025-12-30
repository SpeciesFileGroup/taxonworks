require 'zip'

module Export::Dwca

  class ChecklistData

    # Available extensions.
    DISTRIBUTION_EXTENSION = :distribution
    REFERENCES_EXTENSION = :references
    TYPES_AND_SPECIMEN_EXTENSION = :types_and_specimens
    VERNACULAR_NAME_EXTENSION = :vernacular_name

    CHECKLIST_EXTENSION_OPTIONS = [
      DISTRIBUTION_EXTENSION,
      REFERENCES_EXTENSION,
      TYPES_AND_SPECIMEN_EXTENSION,
      VERNACULAR_NAME_EXTENSION
    ].freeze

    # Accepted name mode values.
    REPLACE_WITH_ACCEPTED_NAME = 'replace_with_accepted_name'
    ACCEPTED_NAME_USAGE_ID = 'accepted_name_usage_id'

    ACCEPTED_NAME_MODE_OPTIONS = [
      REPLACE_WITH_ACCEPTED_NAME,
      ACCEPTED_NAME_USAGE_ID
    ].freeze

    # @return [Array] of rank strings in hierarchical order (highest to lowest).
    # Includes both column-based ranks (kingdom, phylum, etc.) and all possible
    # taxonRank values that may appear for terminal taxa (species, subspecies,
    # variety, form, etc.).
    def self.ordered_ranks
      # Get rank columns available in DwcOccurrence (mapped to DwC field names).
      dwc_rank_columns = ::DwcOccurrence::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys
        .select { |col| [:kingdom, :phylum, :dwcClass, :order, :superfamily, :family, :subfamily, :tribe, :subtribe, :genus, :subgenus].include?(col) }
        .map { |col| col == :dwcClass ? 'class' : col.to_s }

      # Get all species-level ranks from all nomenclatural codes.
      # These can appear as taxonRank values for terminal taxa.
      iczn_species = ::NomenclaturalRank::Iczn::SpeciesGroup.ordered_ranks.map(&:rank_name)
      icn_species = ::NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.ordered_ranks.map(&:rank_name)
      icnp_species = ::NomenclaturalRank::Icnp::SpeciesGroup.ordered_ranks.map(&:rank_name)
      # ICVCN only has "species" rank, no infraspecific ranks.

      species_ranks = (iczn_species + icn_species + icnp_species).uniq

      relevant_ranks = (dwc_rank_columns + species_ranks).uniq

      # Use ICZN ordering as the base (most comprehensive for higher ranks).
      all_iczn = ::NomenclaturalRank::Iczn.ordered_ranks.map(&:rank_name)
      base_order = all_iczn.select { |r| relevant_ranks.include?(r) }

      # Add any species ranks not in ICZN order (like ICN's variety, form).
      missing_ranks = relevant_ranks - base_order
      base_order + missing_ranks
    end

    ORDERED_RANKS = ordered_ranks.freeze

    # @return [Hash] of Otu query params
    #  Required.
    attr_accessor :core_otu_scope_params

    # @return [Scope] of DwcOccurrence
    # Derived from core_otu_scope_params
    attr_accessor :core_occurrence_scope

    # Size of core_occurrence_scope
    attr_accessor :total

    attr_accessor :zipfile

    # Name of the @zipfile
    attr_reader :zipfile_name

    # meta.xml tempfile
    attr_accessor :meta

    # eml.xml tempfile
    attr_accessor :eml

    # data.tsv tempfile
    attr_accessor :data_file

    # Hash mapping taxon_name_id to taxonID for extension star joins.
    # Example: {123 => 5, 456 => 3}
    attr_reader :taxon_name_id_to_taxon_id

    # @return [Boolean] whether to include distribution extension
    attr_accessor :distribution_extension

    # @return [Boolean] whether to include references extension
    attr_accessor :references_extension

    # @return [Boolean] whether to include types and specimen extension
    attr_accessor :types_and_specimen_extension

    # @return [Boolean] whether to include vernacular name extension
    attr_accessor :vernacular_name_extension

    # @return [Array<Symbol>] list of extensions to include
    attr_accessor :extensions

    # @param accepted_name_mode [String] How to handle unaccepted names
    #   'replace_with_accepted_name' - replace invalid names with their valid
    #     names (default)
    #   'accepted_name_usage_id' - include all names, using acceptedNameUsageID
    #     for synonyms
    attr_accessor :accepted_name_mode

    # [Hash] "dwc_occurrence_object_type:dwc_occurrence_object_id" => otu_id
    attr_accessor :occurrence_to_otu

    # Hash otu_id => { cached:, cached_is_valid:, cached_valid_taxon_name_id: }
    attr_accessor :otu_to_taxon_name_data

    def initialize(
      core_otu_scope_params: nil,
      extensions: [],
      accepted_name_mode: 'replace_with_accepted_name'
    )
      @accepted_name_mode = accepted_name_mode

      @core_otu_scope_params = (core_otu_scope_params&.to_h || {}).deep_symbolize_keys

      @extensions = extensions

      @core_occurrence_scope = ::Queries::DwcOccurrence::Filter.new(
        otu_query: @core_otu_scope_params
      ).all

      @distribution_extension = extensions.include?(DISTRIBUTION_EXTENSION)
      @references_extension = extensions.include?(REFERENCES_EXTENSION)
      @types_and_specimen_extension = extensions.include?(TYPES_AND_SPECIMEN_EXTENSION)
      @vernacular_name_extension = extensions.include?(VERNACULAR_NAME_EXTENSION)
    end

    # @return [Array] use the temporarily written, and refined, CSV file to read
    #   off the existing headers so we can use them in writing meta.yml.
    #   Non-standard DwC colums are handled elsewhere.
    def meta_fields
      return [] if no_records?

      # TODO: this is the only place all_data is being called, do we really need all of that?
      h = File.open(all_data, &:gets)&.strip&.split("\t")
      # TODO: is this comment still correct?
      h&.shift # shift because the first column, id, will be specified by hand
      h || []
    end

    def total
      @total ||= core_occurrence_scope.unscope(:order).size
    end

    # @return [Boolean]
    #   true if core_occurrence_scope returns no records
    def no_records?
      total == 0
    end

    # @return [CSV]
    #   The data as a CSV object.
    #   For checklists, this produces a normalized taxonomy (one row per unique
    #   taxon) with sequential taxonIDs and parentNameUsageID relationships -
    #   see https://ipt.gbif.org/manual/en/ipt/latest/best-practices-checklists#normalized-classifications-parentchild
    def csv
      return "\n" if no_records?

      # We need dwc_occurrence_object_type/id for OTU lookups.
      # Don't exclude them initially - we'll remove them after processing.
      excluded_columns = ::DwcOccurrence.excluded_checklist_columns - [:dwc_occurrence_object_type, :dwc_occurrence_object_id]

      # Get raw occurrence data with all taxonomy columns.
      raw_csv = ::Export::CSV.generate_csv(
        core_occurrence_scope.computed_checklist_columns,
        exclude_columns: excluded_columns,
        column_order: ::DwcOccurrence::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys,
        header_converters: [:checklist_headers]
      )

      # Return normalized taxonomy with sequential taxonIDs.
      normalize_taxonomy_csv(raw_csv)
    end

    # Normalize taxonomy: deduplicate, assign sequential taxonIDs, add
    # parentNameUsageID.
    # @param raw_csv [String] CSV with one row per occurrence
    # @return [String] CSV with one row per unique taxon
    def normalize_taxonomy_csv(raw_csv)
      parsed = CSV.parse(raw_csv, headers: true, col_sep: "\t")
      return "\n" if parsed.empty?

      all_taxa = extract_unique_taxa(parsed)

      if accepted_name_mode == 'accepted_name_usage_id'
        all_taxa = ensure_valid_names_for_synonyms(all_taxa, parsed)
      end

      # Build hierarchy and assign taxonIDs (where taxonID is the checklist's
      # taxonID column value).
      processed_taxa, taxon_name_id_to_taxon_id =
        assign_taxon_ids_and_build_hierarchy(all_taxa)

      all_taxa = nil # release memory

      # This is how extensions map back to the core table.
      @taxon_name_id_to_taxon_id = taxon_name_id_to_taxon_id

      processed_taxa = remove_empty_columns(processed_taxa)

      output_headers = processed_taxa.first&.keys || []

      CSV.generate(col_sep: "\t") do |csv|
        csv << output_headers

        processed_taxa.each do |taxon|
          csv << taxon.values
        end
      end
    end

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
          next if columns_with_data.include?(key) # Short-circuit: already found data in this column

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

    # Fetch TaxonName data by unique OTU (not by occurrence).
    # @return [Hash] otu_id => { cached:, cached_is_valid:, cached_valid_taxon_name_id: }
    def otu_to_taxon_name_data
      return @otu_to_taxon_name_data if @otu_to_taxon_name_data

      # Get unique OTU IDs from all three occurrence types
      # This is MUCH faster than joining for every occurrence

      # 1. Get OTU IDs from CollectionObject occurrences
      co_otu_ids = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'CollectionObject')
        .joins('JOIN collection_objects co ON co.id = dwc_occurrences.dwc_occurrence_object_id')
        .joins('JOIN taxon_determinations td ON td.taxon_determination_object_id = co.id AND td.taxon_determination_object_type = \'CollectionObject\' AND td.position = 1')
        .distinct
        .pluck('td.otu_id')

      # 2. Get OTU IDs from FieldOccurrence occurrences
      fo_otu_ids = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'FieldOccurrence')
        .joins('JOIN field_occurrences fo ON fo.id = dwc_occurrences.dwc_occurrence_object_id')
        .joins('JOIN taxon_determinations td ON td.taxon_determination_object_id = fo.id AND td.taxon_determination_object_type = \'FieldOccurrence\' AND td.position = 1')
        .distinct
        .pluck('td.otu_id')

      # 3. Get OTU IDs from AssertedDistribution occurrences
      ad_otu_ids = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'AssertedDistribution')
        .joins('JOIN asserted_distributions ad ON ad.id = dwc_occurrences.dwc_occurrence_object_id AND ad.asserted_distribution_object_type = \'Otu\'')
        .distinct
        .pluck('ad.asserted_distribution_object_id')

      # Combine and get unique OTU IDs
      all_otu_ids = (co_otu_ids + fo_otu_ids + ad_otu_ids).compact.uniq

      return {} if all_otu_ids.empty?

      # Fetch TaxonName data for these OTUs in a single query
      # Also fetch the valid taxon name's cached value for synonyms
      @otu_to_taxon_name_data = ::Otu
        .where(id: all_otu_ids)
        .joins(:taxon_name)
        .joins('LEFT JOIN taxon_names AS valid_taxon_names ON taxon_names.cached_valid_taxon_name_id = valid_taxon_names.id')
        .pluck(
          'otus.id',
          'taxon_names.id',
          'taxon_names.cached',
          'taxon_names.cached_is_valid',
          'taxon_names.cached_valid_taxon_name_id',
          'valid_taxon_names.cached'
        )
        .each_with_object({}) do |row, hash|
          hash[row[0]] = {
            id: row[1],
            cached: row[2],
            cached_is_valid: row[3],
            cached_valid_taxon_name_id: row[4].to_i,
            valid_cached: row[5]
          }
        end

      @otu_to_taxon_name_data
    end

    # Build mapping from occurrence to OTU ID
    # @return [Hash] "dwc_occurrence_object_type:dwc_occurrence_object_id" => otu_id
    def occurrence_to_otu
      return @occurrence_to_otu if @occurrence_to_otu

      # CollectionObject occurrences
      co_mapping = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'CollectionObject')
        .joins('JOIN collection_objects co ON co.id = dwc_occurrences.dwc_occurrence_object_id')
        .joins('JOIN taxon_determinations td ON td.taxon_determination_object_id = co.id AND td.taxon_determination_object_type = \'CollectionObject\' AND td.position = 1')
        .pluck('dwc_occurrences.dwc_occurrence_object_type', 'dwc_occurrences.dwc_occurrence_object_id', 'td.otu_id')
        .each_with_object({}) { |(type, id, otu_id), h| h["#{type}:#{id}"] = otu_id }

      # FieldOccurrence occurrences
      fo_mapping = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'FieldOccurrence')
        .joins('JOIN field_occurrences fo ON fo.id = dwc_occurrences.dwc_occurrence_object_id')
        .joins('JOIN taxon_determinations td ON td.taxon_determination_object_id = fo.id AND td.taxon_determination_object_type = \'FieldOccurrence\' AND td.position = 1')
        .pluck('dwc_occurrences.dwc_occurrence_object_type', 'dwc_occurrences.dwc_occurrence_object_id', 'td.otu_id')
        .each_with_object({}) { |(type, id, otu_id), h| h["#{type}:#{id}"] = otu_id }

      # AssertedDistribution occurrences
      ad_mapping = core_occurrence_scope
        .where(dwc_occurrence_object_type: 'AssertedDistribution')
        .joins('JOIN asserted_distributions ad ON ad.id = dwc_occurrences.dwc_occurrence_object_id AND ad.asserted_distribution_object_type = \'Otu\'')
        .pluck('dwc_occurrences.dwc_occurrence_object_type', 'dwc_occurrences.dwc_occurrence_object_id', 'ad.asserted_distribution_object_id')
        .each_with_object({}) { |(type, id, otu_id), h| h["#{type}:#{id}"] = otu_id }

      @occurrence_to_otu = co_mapping.merge(fo_mapping).merge(ad_mapping)
      @occurrence_to_otu
    end

    # Extract all unique taxa from occurrence data.
    # Uses taxon_name_id as the key to handle homonyms correctly.
    # @param parsed [CSV::Table] parsed occurrence data
    # @return [Hash] hash of taxon_name_id => taxon data
    def extract_unique_taxa(parsed)
      # Be aware: we're loading the entire checklist's data into this hash -
      # rough estimate 50MB for 50k taxa.
      all_taxa = {}
      batch_size = 25_000

      parsed.each_slice(batch_size) do |batch|
        terminal_ids = collect_terminal_ids_for_batch(batch)
        ancestor_lookup = build_ancestor_lookup(terminal_ids)

        batch.each do |row|
          process_occurrence_row(row, all_taxa, ancestor_lookup)
        end
      end

      all_taxa
    end

    # Collect unique terminal taxon_name_ids from a batch of occurrence rows.
    # @param batch [Array<CSV::Row>] batch of occurrence rows
    # @return [Array<Integer>] unique terminal taxon_name_ids
    def collect_terminal_ids_for_batch(batch)
      batch.map { |row|
        occurrence_key = "#{row['dwc_occurrence_object_type']}:#{row['dwc_occurrence_object_id']}"

        tn_data = otu_to_taxon_name_data[occurrence_to_otu[occurrence_key]]
        next unless tn_data

        # Use valid taxon_name_id in replace mode, actual id in accepted_name_usage_id mode
        if accepted_name_mode == 'replace_with_accepted_name'
          tn_data[:cached_valid_taxon_name_id] || tn_data[:id]
        else
          tn_data[:id]
        end
      }.compact.uniq
    end

    # Build a lookup hash for ancestor taxon_name_ids from terminal taxon_name_ids.
    # @param terminal_taxon_name_ids [Array<Integer>] IDs of terminal TaxonNames
    # @return [Hash] "terminal_tn_id:rank" => ancestor_tn_id
    def build_ancestor_lookup(terminal_taxon_name_ids)
      return {} if terminal_taxon_name_ids.empty?

      lookup = {}

      # Query taxon_name_hierarchies WITHOUT join (much faster).
      hierarchy_relationships = TaxonNameHierarchy
        .where(descendant_id: terminal_taxon_name_ids)
        .where.not('ancestor_id = descendant_id') # exclude self-references
        .pluck(:descendant_id, :ancestor_id)

      all_ancestor_ids =
        hierarchy_relationships.map { |_, ancestor_id| ancestor_id }.uniq

      ancestor_ranks = ::TaxonName
        .where(id: all_ancestor_ids)
        .pluck(:id, :rank_class)
        .to_h

      # Build lookup hash: "terminal_id:rank" => ancestor_id
      hierarchy_relationships.each do |descendant_id, ancestor_id|
        rank_class = ancestor_ranks[ancestor_id]
        next unless rank_class

        rank = rank_class_to_name[rank_class]
        next unless rank

        key = "#{descendant_id}:#{rank}"
        lookup[key] = ancestor_id
      end

      lookup
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
    def process_occurrence_row(row, all_taxa, ancestor_lookup)
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
        row, terminal_tn_id, terminal_rank, all_taxa, ancestor_lookup
      )
      extract_ancestor_taxa(
        row, terminal_tn_id, terminal_rank, ancestor_lookup, all_taxa
      )
    end

    # Store TaxonName metadata in row for accepted_name_usage_id mode for later
    # reference.
    # @param row [CSV::Row] occurrence row to modify
    # @param tn_data [Hash] taxon name data
    def store_taxon_name_metadata(row, tn_data)
      return unless tn_data[:cached].present?

      row['taxon_name_cached'] = tn_data[:cached]
      row['taxon_name_cached_is_valid'] = tn_data[:cached_is_valid]
      row['taxon_name_cached_valid_taxon_name_id'] = tn_data[:cached_valid_taxon_name_id]
    end

    # Add terminal taxon to all_taxa if not already present.
    # @param row [CSV::Row] occurrence row
    # @param terminal_tn_id [Integer] terminal taxon_name_id
    # @param terminal_rank [String] rank of terminal taxon
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @param ancestor_lookup [Hash] precomputed ancestor lookup
    def add_terminal_taxon(
      row, terminal_tn_id, terminal_rank, all_taxa, ancestor_lookup
    )
      return if all_taxa[terminal_tn_id]

      taxon = row.to_h
      taxon['taxon_name_id'] = terminal_tn_id

      # In accepted_name_usage_id mode, use original name if available.
      if row['taxon_name_cached'].present?
        taxon['scientificName'] = row['taxon_name_cached']
      end

      all_taxa[terminal_tn_id] = taxon

      # Extract parent species for infraspecific taxa.
      if self.class.infraspecific_rank_names.include?(terminal_rank)
        extract_parent_species_for_taxon(
          row, terminal_rank, terminal_tn_id, ancestor_lookup, all_taxa
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
      row, rank, terminal_tn_id, ancestor_lookup, all_taxa
    )
      genus = row['genus']
      specific_epithet = row['specificEpithet']

      if genus.present? && specific_epithet.present?
        species_tn_id = ancestor_lookup["#{terminal_tn_id}:species"]
        return unless species_tn_id
        return if all_taxa[species_tn_id] # Already extracted

        # Create species taxon (DwcOccurrence table doesn't include species
        # column).
        species_taxon = row.to_h.dup
        species_taxon['taxon_name_id'] = species_tn_id
        species_taxon['scientificName'] = "#{genus} #{specific_epithet}" # no author
        species_taxon['taxonRank'] = 'species'
        clear_lower_ranks(species_taxon, 'species', rank)

        # Clear taxon_name_ metadata since this is an extracted parent.
        species_taxon['taxon_name_cached'] = nil
        species_taxon['taxon_name_cached_is_valid'] = nil
        species_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

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
      row, terminal_tn_id, terminal_rank, ancestor_lookup, all_taxa
    )
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
        clear_lower_ranks(ancestor_taxon, higher_rank, terminal_rank)

        # Clear taxon_name_ metadata for extracted ancestors.
        ancestor_taxon['taxon_name_cached'] = nil
        ancestor_taxon['taxon_name_cached_is_valid'] = nil
        ancestor_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

        all_taxa[ancestor_tn_id] = ancestor_taxon
      end
    end

    # Ensure valid names exist for all synonyms.
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @param parsed [CSV::Table] parsed occurrence data (to get TaxonName data)
    # @return [Hash] updated all_taxa with valid names added
    def ensure_valid_names_for_synonyms(all_taxa, parsed)
      # Track valid TaxonName IDs we need to fetch.
      valid_taxon_name_ids = Set.new

      # Find all synonyms and collect their valid_taxon_name_ids.
      all_taxa.each_value do |taxon|
        # Check if this is a synonym (not valid).
        is_valid = taxon['taxon_name_cached_is_valid']
        next unless !is_valid.nil? && !['t', 'true', true, 1, '1'].include?(is_valid)

        valid_id = taxon['taxon_name_cached_valid_taxon_name_id']
        valid_taxon_name_ids << valid_id if valid_id.present?
      end

      return all_taxa if valid_taxon_name_ids.empty?

      # Fetch valid TaxonName records.
      valid_taxon_names = ::TaxonName.where(id: valid_taxon_name_ids.to_a).includes(:ancestor_hierarchies)

      # Create taxa for valid names that don't exist yet
      valid_taxon_names.each do |valid_tn|
        rank = valid_tn.rank&.downcase
        next if rank.nil?

        # Use taxon_name_id as key (not "rank:name")
        next if all_taxa[valid_tn.id] # already exists

        # Find a synonym that points to this valid name to use as template.
        template_taxon = all_taxa.each_value.find do |t|
          vid = t['taxon_name_cached_valid_taxon_name_id']
          vid.present? && (vid == valid_tn.id)
        end

        next unless template_taxon

        valid_taxon = template_taxon.dup
        valid_taxon['taxon_name_id'] = valid_tn.id
        valid_taxon['scientificName'] = valid_tn.cached
        valid_taxon['taxonRank'] = rank
        valid_taxon['taxon_name_cached'] = valid_tn.cached
        valid_taxon['taxon_name_cached_is_valid'] = 't' # TODO
        valid_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

        clear_lower_ranks(valid_taxon, rank, template_taxon['taxonRank']&.downcase)

        all_taxa[valid_tn.id] = valid_taxon
      end

      all_taxa
    end

    # Assign sequential taxonIDs and parentNameUsageIDs to all taxa.
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @return [Array] [processed_taxa, taxon_name_id_to_taxon_id] - processed
    #   taxa array and taxon_name_id-to-taxonID mapping
    def assign_taxon_ids_and_build_hierarchy(all_taxa)
      taxon_name_info = fetch_taxon_name_info(all_taxa)
      taxa_with_ids, taxon_name_id_to_taxon_id =
        assign_sequential_taxon_ids(all_taxa, taxon_name_info)
      processed_taxa = build_processed_taxa(
        taxa_with_ids, taxon_name_info, taxon_name_id_to_taxon_id
      )

      [processed_taxa, taxon_name_id_to_taxon_id]
    end

    # Fetch rank and parent_id information for taxon_name_ids.
    # Uses lazy iteration via each_key to avoid materializing intermediate arrays.
    # @param all_taxa [Hash] taxon_name_id => taxon data
    # @return [Hash] taxon_name_id => { rank:, parent_id: }
    def fetch_taxon_name_info(all_taxa)
      taxon_name_info = {}
      all_taxa.each_key.each_slice(25_000) do |tn_ids|
        ::TaxonName.where(id: tn_ids).find_each do |tn|
          taxon_name_info[tn.id] = {
            rank: tn.rank&.downcase,
            parent_id: tn.parent_id
          }
        end
      end

      taxon_name_info
    end

    # Assign sequential taxonIDs to all taxa, grouped by rank.
    # @param all_taxa [Hash] taxon_name_id => taxon data
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id: }
    # @return [Array] [taxa_with_ids, taxon_name_id_to_taxon_id mapping]
    def assign_sequential_taxon_ids(all_taxa, taxon_name_info)
      taxon_id_counter = 1
      taxon_name_id_to_taxon_id = {}
      taxa_with_ids = []

      ORDERED_RANKS.each do |rank|
        rank_taxa = all_taxa.select { |tn_id, taxon|
          taxon_name_info[tn_id]&.[](:rank) == rank
        }.sort_by { |tn_id, taxon| taxon['scientificName'] || '' }

        rank_taxa.each do |tn_id, taxon|
          next if taxon_name_id_to_taxon_id[tn_id]

          taxon_id = taxon_id_counter
          taxon_id_counter += 1
          taxon_name_id_to_taxon_id[tn_id] = taxon_id

          taxa_with_ids << {
             taxon: taxon, taxon_id: taxon_id, taxon_name_id: tn_id, rank: rank
          }
        end
      end

      [taxa_with_ids, taxon_name_id_to_taxon_id]
    end

    # Build final processed taxa with parent/accepted relationships.
    # @param taxa_with_ids [Array<Hash>] taxa with assigned IDs
    # @param taxon_name_info [Hash] taxon_name_id => { rank:, parent_id: }
    # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => taxonID
    # @return [Array<Hash>] processed taxa ready for export
    def build_processed_taxa(
      taxa_with_ids, taxon_name_info, taxon_name_id_to_taxon_id
    )
      taxa_with_ids.map do |item|
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
      # Find parent via TaxonName parent_id
      parent_taxon_name_id = taxon_name_info[taxon_name_id]&.[](:parent_id)
      parent_id = parent_taxon_name_id ?
        taxon_name_id_to_taxon_id[parent_taxon_name_id] : nil

      # TODO
      excluded_fields = [
        'taxonID', 'id', 'acceptedNameUsageID', 'parentNameUsageID',
        'taxon_name_cached', 'taxon_name_cached_is_valid',
        'taxon_name_cached_valid_taxon_name_id', 'taxon_name_id',
        'dwc_occurrence_object_type', 'dwc_occurrence_object_id'
      ]
      excluded_fields << 'taxonomicStatus' if accepted_name_mode == 'accepted_name_usage_id'

      # Build base fields.
      processed_taxon = {
        'id' => taxon_id,
        'taxonID' => taxon_id,
        'parentNameUsageID' => parent_id
      }

      if accepted_name_mode == 'accepted_name_usage_id'
        accepted_name_usage_id, taxonomic_status = determine_accepted_name_usage(
          taxon,
          taxon_id,
          taxon_name_id_to_taxon_id
        )
        processed_taxon['acceptedNameUsageID'] = accepted_name_usage_id
        processed_taxon['taxonomicStatus'] = taxonomic_status
      end

      processed_taxon.merge!(taxon.except(*excluded_fields))
    end

    # Determine acceptedNameUsageID and taxonomicStatus for a taxon.
    # @param taxon [Hash] taxon data
    # @param taxon_id [Integer] assigned taxonID
    # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => taxonID
    # @return [Array] [acceptedNameUsageID, taxonomicStatus]
    def determine_accepted_name_usage(taxon, taxon_id, taxon_name_id_to_taxon_id)
      return [nil, nil] unless accepted_name_mode == 'accepted_name_usage_id'

      is_valid = taxon['taxon_name_cached_is_valid']

      if !is_valid.nil?
        # We have definitive validity data from a terminal TaxonName.
        # Check if valid - handle both boolean and string representations
        if [true, 't', 'true', 1, '1'].include?(is_valid) # TODO
          [taxon_id, 'accepted']
        else
          # This taxon is marked as invalid (synonym).
          valid_taxon_name_id = taxon['taxon_name_cached_valid_taxon_name_id']
          if valid_taxon_name_id.present?
            accepted_id = taxon_name_id_to_taxon_id[valid_taxon_name_id]
            [accepted_id, 'synonym']
          else
            [nil, nil]
          end
        end
      else
        # No validity data (is_valid is nil) - this is an extracted higher taxon
        # from rank columns. These represent accepted names because
        # DwcOccurrence always builds higher classification from
        # valid_taxon_name.
        [taxon_id, 'accepted']
      end
    end

    # Clear columns for ranks lower than the current rank this taxon is being
    # assigned to and recompute higherClassification.
    # @param taxon [Hash] the taxon data hash to modify
    # @param current_rank [String] the rank being extracted
    # @param original_rank [String] the original taxonRank before extraction
    def clear_lower_ranks(taxon, current_rank, original_rank = nil)
      current_id = ORDERED_RANKS.index(current_rank)
      return unless current_id

      # If extracting a taxon at the same rank as the original row, keep all
      # fields as-is since they're all valid (this happens when the terminal
      # taxon appears in a rank column, e.g., monotypic genus).
      return if current_rank == original_rank

      # Clear lower rank columns
      ORDERED_RANKS[(current_id + 1)..-1].each do |lower_rank|
        taxon[lower_rank] = nil
      end

      # Fields to keep for extracted taxa (rank columns + core fields + epithet
      # fields based on rank).
      rank_columns = ORDERED_RANKS.map(&:to_s)
      fields_to_keep =
        rank_columns + ['scientificName', 'taxonRank', 'nomenclaturalCode']

      # Add epithet fields to keep based on rank:
      # - Species: keep specificEpithet
      # - Infraspecific (subspecies, variety, form, etc.): keep both epithet fields
      # - Higher ranks (genus, family, etc.): don't keep epithet fields
      if current_rank == 'species'
        fields_to_keep << 'specificEpithet'
      elsif self.class.infraspecific_rank_names.include?(current_rank)
        fields_to_keep << 'specificEpithet'
        fields_to_keep << 'infraspecificEpithet'
      end

      # Clear all other taxon-specific fields from the original terminal taxon.
      ::DwcOccurrence::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys.each do |field|
        field_str = field.to_s
        # Convert dwcClass to 'class' for comparison
        field_str = 'class' if field == :dwcClass
        taxon[field_str] = nil unless fields_to_keep.include?(field_str)
      end

      # Recompute higherClassification for this rank from higher rank columns.
      higher_ranks = ORDERED_RANKS[0...current_id]
      classification_parts = higher_ranks.map { |r| taxon[r] }.compact.reject(&:empty?)
      taxon['higherClassification'] = classification_parts.empty? ?
        nil : classification_parts.join(Export::Dwca::DELIMITER)
    end

    # Get all infraspecific rank names (species-level ranks excluding "species"
    # itself).
    def self.infraspecific_rank_names
      @infraspecific_rank_names ||= begin
        iczn = ::NomenclaturalRank::Iczn::SpeciesGroup.ordered_ranks.map(&:rank_name)
        icn = ::NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.ordered_ranks.map(&:rank_name)
        icnp = ::NomenclaturalRank::Icnp::SpeciesGroup.ordered_ranks.map(&:rank_name)

        all_species_ranks = (iczn + icn + icnp).uniq
        all_species_ranks - ['species']
      end
    end

    # @return [Tempfile]
    #   the csv data as a tempfile
    def data_file
      return @data_file if @data_file

      if no_records?
        content = "\n"
      else
        content = csv
      end

      @data_file = Tempfile.new('data.tsv')
      @data_file.write(content)
      @data_file.flush
      @data_file.rewind

      Rails.logger.debug 'dwca_checklist_export: data written'

      @data_file
    end

    # This is a stub, and only half-heartedly done. You should be using IPT for
    # the time being.
    # @return [Tempfile]
    #   metadata about this dataset
    # See also
    #    https://github.com/gbif/ipt/wiki/resourceMetadata
    #    https://github.com/gbif/ipt/wiki/resourceMetadata#exemplar-datasets
    #
    def eml
      return @eml if @eml

      @eml = Tempfile.new('eml.xml')

      eml_xml = ::Export::Dwca::Eml.actualized_stub_eml

      @eml.write(eml_xml)
      @eml.flush
      @eml
    end

    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          # Core
          # TODO: fix rowType
          # TODO: '\n' or '\\n' or "\n"? same for \t
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.tsv'
            }
            xml.id(index: 0) # Must be named id
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i + 1, term: h)
              else
                # TODO: namespace should go with column name, like extensions do
                xml.field(index: i + 1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }

          # Species Distribution extension
          if distribution_extension
            # TODO: Factor this whole thing out for all extensions
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\\n', fieldsTerminatedBy: '\\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.gbif.org/terms/1.0/Distribution') {
              xml.files {
                xml.location 'distribution.tsv'
              }
              Export::CSV::Dwc::Extension::Checklist::SpeciesDistribution::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First distribution column (id) should have namespace '', got '#{n}'")
                  xml.id(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # Literature References extension
          if references_extension
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\\n', fieldsTerminatedBy: '\\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.gbif.org/terms/1.0/Reference') {
              xml.files {
                xml.location 'references.tsv'
              }
              Export::CSV::Dwc::Extension::Checklist::References::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First references column (id) should have namespace '', got '#{n}'")
                  xml.id(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # Types and Specimen extension
          if types_and_specimen_extension
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\\n', fieldsTerminatedBy: '\\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.gbif.org/terms/1.0/TypesAndSpecimen') {
              xml.files {
                xml.location 'types_and_specimen.tsv'
              }
              Export::CSV::Dwc::Extension::Checklist::TypesAndSpecimen::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First types_and_specimen column (id) should have namespace '', got '#{n}'")
                  xml.id(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # Vernacular Name extension
          if vernacular_name_extension
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\\n', fieldsTerminatedBy: '\\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.gbif.org/terms/1.0/VernacularName') {
              xml.files {
                xml.location 'vernacular_name.tsv'
              }
              Export::CSV::Dwc::Extension::Checklist::VernacularName::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First vernacular_name column (id) should have namespace '', got '#{n}'")
                  xml.id(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end
        }
      end

      @meta.write(builder.to_xml)
      @meta.flush
      @meta.rewind
      @meta
    end

    # @return [Tempfile, nil]
    #   Species distribution extension data from AssertedDistribution records.
    def distribution_extension_tmp
      # TODO: factor this all out for all extensions
      return nil unless distribution_extension
      @distribution_extension_tmp = Tempfile.new('distribution.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_id_to_taxon_id mapping
        # if not already done (for specs).
        csv unless taxon_name_id_to_taxon_id

        # Only export distribution extension for AssertedDistribution-based
        # DwcOccurrence records.
        distribution_scope = core_occurrence_scope.where(dwc_occurrence_object_type: 'AssertedDistribution')

        content = Export::CSV::Dwc::Extension::Checklist::SpeciesDistribution.csv(distribution_scope, taxon_name_id_to_taxon_id)
      end

      @distribution_extension_tmp.write(content)
      @distribution_extension_tmp.flush
      @distribution_extension_tmp.rewind
      @distribution_extension_tmp
    end

    # @return [Tempfile, nil]
    #   Literature references extension data.
    def references_extension_tmp
      return nil unless references_extension
      @references_extension_tmp = Tempfile.new('references.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_id_to_taxon_id mapping
        # if not already done (for specs).
        csv unless taxon_name_id_to_taxon_id

        # Export references for all DwcOccurrence records
        # (only AssertedDistribution records have associatedReferences populated).
        content = Export::CSV::Dwc::Extension::Checklist::References.csv(core_occurrence_scope, taxon_name_id_to_taxon_id)
      end

      @references_extension_tmp.write(content)
      @references_extension_tmp.flush
      @references_extension_tmp.rewind
      @references_extension_tmp
    end

    def types_and_specimen_extension_tmp
      return nil unless types_and_specimen_extension
      @types_and_specimen_extension_tmp = Tempfile.new('types_and_specimen.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_id_to_taxon_id mapping
        # if not already done (for specs).
        csv unless taxon_name_id_to_taxon_id

        # Export types and specimen for CollectionObject DwcOccurrence records
        # (only CollectionObject records with typeStatus populated).
        content = Export::CSV::Dwc::Extension::Checklist::TypesAndSpecimen.csv(core_occurrence_scope, taxon_name_id_to_taxon_id)
      end

      @types_and_specimen_extension_tmp.write(content)
      @types_and_specimen_extension_tmp.flush
      @types_and_specimen_extension_tmp.rewind
      @types_and_specimen_extension_tmp
    end

    def vernacular_name_extension_tmp
      return nil unless vernacular_name_extension
      @vernacular_name_extension_tmp = Tempfile.new('vernacular_name.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_id_to_taxon_id mapping
        # if not already done (for specs).
        csv unless taxon_name_id_to_taxon_id

        # Export vernacular names from CommonName records
        # Note: NOT using DwcOccurrence (vernacularName field not populated).
        content = Export::CSV::Dwc::Extension::Checklist::VernacularName.csv(core_otu_scope_params, taxon_name_id_to_taxon_id)
      end

      @vernacular_name_extension_tmp.write(content)
      @vernacular_name_extension_tmp.flush
      @vernacular_name_extension_tmp.rewind
      @vernacular_name_extension_tmp
    end

    def build_zip
      t = Tempfile.new(zipfile_name)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, Zip::File::CREATE) do |zip|
        zip.add('data.tsv', data_file.path)

        zip.add('distribution.tsv', distribution_extension_tmp.path) if distribution_extension
        zip.add('references.tsv', references_extension_tmp.path) if references_extension
        zip.add('types_and_specimen.tsv', types_and_specimen_extension_tmp.path) if types_and_specimen_extension
        zip.add('vernacular_name.tsv', vernacular_name_extension_tmp.path) if vernacular_name_extension

        zip.add('meta.xml', meta.path)
        zip.add('eml.xml', eml.path)
      end

      t
    end

    # @return [Tempfile]
    #   the zipfile
    def zipfile
      @zipfile ||= build_zip
      @zipfile
    end

    # @return [String]
    # the name of zipfile
    def zipfile_name
      @zipfile_name ||= "dwc_checklist_#{DateTime.now}.zip"
      @zipfile_name
    end


    # @param download [a Download]
    def package_download(download)
      p = zipfile.path

      # This doesn't touch the db (source_file_path is an instance var).
      download.update!(source_file_path: p)
    end

    # @return [Tempfile]
    #   the combined data file
    def all_data
      return @all_data if @all_data

      @all_data = Tempfile.new('data.tsv')

      join_data = [data_file]

      # Combine all data files
      join_data.each_with_index do |file, i|
        file.rewind
        if i == 0
          @all_data.write(file.read)
        else
          # Skip header line for subsequent files.
          file.gets
          @all_data.write(file.read)
        end
      end

      @all_data.flush
      @all_data.rewind
      @all_data
    end

    # Cleanup temporary files
    def cleanup
      zipfile.close if zipfile
      zipfile.unlink if zipfile

      data_file.close if data_file
      data_file.unlink if data_file

      @all_data.close if @all_data
      @all_data.unlink if @all_data

      if distribution_extension && @distribution_extension_tmp
        @distribution_extension_tmp.close
        @distribution_extension_tmp.unlink
      end

      if references_extension && @references_extension_tmp
        @references_extension_tmp.close
        @references_extension_tmp.unlink
      end

      if types_and_specimen_extension && @types_and_specimen_extension_tmp
        @types_and_specimen_extension_tmp.close
        @types_and_specimen_extension_tmp.unlink
      end

      if vernacular_name_extension && @vernacular_name_extension_tmp
        @vernacular_name_extension_tmp.close
        @vernacular_name_extension_tmp.unlink
      end

      eml.close if eml
      eml.unlink if eml

      meta.close if meta
      meta.unlink if meta

      true
    end
  end
end