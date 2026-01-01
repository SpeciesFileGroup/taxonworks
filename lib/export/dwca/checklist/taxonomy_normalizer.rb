module Export::Dwca::Checklist
  # Service object for normalizing taxonomy from occurrence-based CSV to
  # deduplicated taxon-based CSV with sequential taxonIDs and parent/child
  # relationships.
  #
  # Handles:
  # - Extracting unique taxa from occurrence data
  # - Building taxonomic hierarchy from rank columns
  # - Assigning sequential taxonIDs
  # - Creating parentNameUsageID relationships
  # - Handling synonyms in accepted_name_usage_id mode
  class TaxonomyNormalizer
    # @return [Array] of rank strings in hierarchical order (highest to lowest).
    ORDERED_RANKS = Data::ORDERED_RANKS

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

      all_taxa = extract_unique_taxa(parsed)

      if @accepted_name_mode == 'accepted_name_usage_id'
        all_taxa = ensure_valid_names_for_synonyms(all_taxa, parsed)
      end

      # Build hierarchy and assign taxonIDs
      processed_taxa, taxon_name_id_to_taxon_id =
        assign_taxon_ids_and_build_hierarchy(all_taxa)

      all_taxa = nil # release memory

      processed_taxa = remove_empty_columns(processed_taxa)

      output_headers = processed_taxa.first&.keys || []

      csv_output = CSV.generate(col_sep: "\t") do |csv|
        csv << output_headers

        processed_taxa.each do |taxon|
          csv << taxon.values
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
          next if columns_with_data.include?(key) # Short-circuit

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
    # @return [Hash] hash of taxon_name_id => taxon data
    def extract_unique_taxa(parsed)
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

    # Store TaxonName metadata in row for accepted_name_usage_id mode
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

        # Create species taxon
        species_taxon = row.to_h.dup
        species_taxon['taxon_name_id'] = species_tn_id
        species_taxon['scientificName'] = "#{genus} #{specific_epithet}"
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
        is_valid = taxon['taxon_name_cached_is_valid']
        next unless !is_valid.nil? && is_valid != true

        valid_id = taxon['taxon_name_cached_valid_taxon_name_id']
        valid_taxon_name_ids << valid_id if valid_id.present?
      end

      return all_taxa if valid_taxon_name_ids.empty?

      # Fetch valid TaxonName records.
      valid_taxon_names = ::TaxonName.where(id: valid_taxon_name_ids.to_a)

      # Build reverse lookup: valid_taxon_name_id => synonym taxon
      synonym_to_valid = all_taxa.each_value.each_with_object({}) do |taxon, hash|
        valid_id = taxon['taxon_name_cached_valid_taxon_name_id']
        hash[valid_id] ||= taxon if valid_id.present?
      end

      # Create taxa for valid names that don't exist yet
      valid_taxon_names.each do |valid_tn|
        rank = valid_tn.rank&.downcase
        next if rank.nil?
        next if all_taxa[valid_tn.id] # already exists

        # Find a synonym that points to this valid name to use as template
        template_taxon = synonym_to_valid[valid_tn.id]
        next unless template_taxon

        valid_taxon = template_taxon.dup
        valid_taxon['taxon_name_id'] = valid_tn.id
        valid_taxon['scientificName'] = valid_tn.cached
        valid_taxon['taxonRank'] = rank
        valid_taxon['taxon_name_cached'] = valid_tn.cached
        valid_taxon['taxon_name_cached_is_valid'] = true
        valid_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

        clear_lower_ranks(valid_taxon, rank, template_taxon['taxonRank']&.downcase)

        all_taxa[valid_tn.id] = valid_taxon
      end

      all_taxa
    end

    # Assign sequential taxonIDs and parentNameUsageIDs to all taxa.
    # @param all_taxa [Hash] hash of taxon_name_id => taxon data
    # @return [Array] [processed_taxa, taxon_name_id_to_taxon_id]
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
    # @param all_taxa [Hash] taxon_name_id => taxon data
    # @return [Hash] taxon_name_id => { rank:, parent_id: }
    def fetch_taxon_name_info(all_taxa)
      taxon_name_info = {}

      # Get all taxon_name_ids including self and all ancestors
      all_ids = []
      all_taxa.keys.each_slice(25_000) do |tn_ids|
        ids = TaxonNameHierarchy
          .where(descendant_id: tn_ids)
          .pluck(:ancestor_id)
          .uniq
        all_ids.concat(ids)
      end

      # Fetch info for all taxa and ancestors using pluck (faster than find_each when IDs known)
      all_ids.uniq.each_slice(25_000) do |ids|
        ::TaxonName.where(id: ids)
          .pluck(:id, :rank_class, :parent_id)
          .each { |(id, rank_class, parent_id)|
            rank = rank_class_to_name[rank_class]&.downcase
            taxon_name_info[id] = { rank: rank, parent_id: parent_id }
          }
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
      # Find parent via TaxonName parent_id, walking up hierarchy if needed.
      parent_id = nil
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

      # Exclude fields
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
        if is_valid == true
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
        # No validity data - this is an extracted higher taxon from rank columns.
        [taxon_id, 'accepted']
      end
    end

    # Clear columns for ranks lower than the current rank and recompute higherClassification.
    # @param taxon [Hash] the taxon data hash to modify
    # @param current_rank [String] the rank being extracted
    # @param original_rank [String] the original taxonRank before extraction
    def clear_lower_ranks(taxon, current_rank, original_rank = nil)
      current_id = ORDERED_RANKS.index(current_rank)
      return unless current_id

      # If extracting at same rank as original, keep all fields
      return if current_rank == original_rank

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
      ::DwcOccurrence::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys.each do |field|
        field_str = field.to_s
        field_str = 'class' if field == :dwcClass
        taxon[field_str] = nil unless fields_to_keep.include?(field_str)
      end

      # Recompute higherClassification
      higher_ranks = ORDERED_RANKS[0...current_id]
      classification_parts = higher_ranks.map { |r| taxon[r] }.compact.reject(&:empty?)
      taxon['higherClassification'] = classification_parts.empty? ?
        nil : classification_parts.join(Export::Dwca::DELIMITER)
    end

    # Get all infraspecific rank names
    def self.infraspecific_rank_names
      @infraspecific_rank_names ||= begin
        iczn = ::NomenclaturalRank::Iczn::SpeciesGroup.ordered_ranks.map(&:rank_name)
        icn = ::NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.ordered_ranks.map(&:rank_name)
        icnp = ::NomenclaturalRank::Icnp::SpeciesGroup.ordered_ranks.map(&:rank_name)

        all_species_ranks = (iczn + icn + icnp).uniq
        all_species_ranks - ['species']
      end
    end
  end
end
