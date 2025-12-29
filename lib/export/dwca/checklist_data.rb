require 'zip'

module Export::Dwca

  class ChecklistData

    # Extension constants - callers pass array of these to specify which extensions to include
    DISTRIBUTION_EXTENSION = :distribution
    REFERENCES_EXTENSION = :references
    TYPES_AND_SPECIMEN_EXTENSION = :types_and_specimen
    VERNACULAR_NAME_EXTENSION = :vernacular_name

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
    attr_reader :filename

    attr_accessor :meta

    attr_accessor :eml

    attr_accessor :data_file

    # Hash mapping "rank:scientificName" to taxonID for extension star joins
    # Example: {"species:Rosa alba" => 5, "genus:Rosa" => 3}
    attr_reader :taxon_name_to_id

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
    #   'replace_with_accepted_name' - replace invalid names with their valid names (default)
    #   'accepted_name_usage_id' - include all names, using acceptedNameUsageID for synonyms
    attr_accessor :accepted_name_mode

    def initialize(core_otu_scope_params: nil, extensions: [], accepted_name_mode: 'replace_with_accepted_name')
      @accepted_name_mode = accepted_name_mode

      # Convert to regular Hash first to avoid gnfinder gem's buggy deep_symbolize_keys! implementation
      @core_otu_scope_params = (core_otu_scope_params&.to_h || {}).deep_symbolize_keys

      @extensions = extensions

      @core_occurrence_scope = ::Queries::DwcOccurrence::Filter.new(
        otu_query: @core_otu_scope_params
      ).all

      # Fetch TaxonName data to handle synonym replacement and acceptedNameUsageID
      @taxon_name_data = fetch_taxon_name_data
      @occurrence_to_otu = fetch_occurrence_to_otu_mapping

      # Set extension flags based on requested extensions
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

      h = File.open(all_data, &:gets)&.strip&.split("\t")
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

      # We need dwc_occurrence_object_type/id for OTU lookups
      # Don't exclude them initially - we'll remove them after processing
      excluded_columns = ::DwcOccurrence::EXCLUDED_CHECKLIST_COLUMNS - [:dwc_occurrence_object_type, :dwc_occurrence_object_id]

      # Get raw occurrence data with all taxonomy columns.
      raw_csv = ::Export::CSV.generate_csv(
        core_occurrence_scope.computed_checklist_columns,
        exclude_columns: excluded_columns,
        column_order: ::DwcOccurrence::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys,
        trim_columns: false, # Keep all columns for now
        trim_rows: false,
        header_converters: [:checklist_headers]
      )

      # Build normalized taxonomy with sequential taxonIDs
      normalize_taxonomy_csv(raw_csv)
    end

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

    # Normalize taxonomy: deduplicate, assign sequential taxonIDs, add
    # parentNameUsageID.
    # @param raw_csv [String] CSV with one row per occurrence
    # @return [String] CSV with one row per unique taxon
    def normalize_taxonomy_csv(raw_csv)
      parsed = CSV.parse(raw_csv, headers: true, col_sep: "\t")
      return "\n" if parsed.empty?

      all_taxa = extract_unique_taxa(parsed)

      # In accepted_name_usage_id mode, ensure valid names exist for all synonyms
      if accepted_name_mode == 'accepted_name_usage_id'
        all_taxa = ensure_valid_names_for_synonyms(all_taxa, parsed)
      end

      processed_taxa, name_to_id = assign_taxon_ids_and_build_hierarchy(all_taxa)

      # Store the name-to-ID mapping for extensions to use
      @taxon_name_to_id = name_to_id

      # Remove empty columns to reduce file size and improve readability
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

    # Fetch TaxonName data by unique OTU (not by occurrence)
    # @return [Hash] otu_id => { cached:, cached_is_valid:, cached_valid_taxon_name_id: }
    def fetch_taxon_name_data
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
      ::Otu
        .where(id: all_otu_ids)
        .joins(:taxon_name)
        .joins('LEFT JOIN taxon_names AS valid_taxon_names ON taxon_names.cached_valid_taxon_name_id = valid_taxon_names.id')
        .pluck(
          'otus.id',
          'taxon_names.cached',
          'taxon_names.cached_is_valid',
          'taxon_names.cached_valid_taxon_name_id',
          'valid_taxon_names.cached'
        )
        .each_with_object({}) do |row, hash|
          hash[row[0]] = {
            cached: row[1],
            cached_is_valid: row[2],
            cached_valid_taxon_name_id: row[3],
            valid_cached: row[4]
          }
        end
    end

    # Build mapping from occurrence to OTU ID
    # @return [Hash] "dwc_occurrence_object_type:dwc_occurrence_object_id" => otu_id
    def fetch_occurrence_to_otu_mapping
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

      co_mapping.merge(fo_mapping).merge(ad_mapping)
    end

    # Extract all unique taxa from occurrence data.
    # @param parsed [CSV::Table] parsed occurrence data
    # @return [Hash] hash of "rank:name" => taxon data
    def extract_unique_taxa(parsed)
      all_taxa = {}

      parsed.each do |row|
        # Look up TaxonName data to handle synonyms
        if @taxon_name_data && @occurrence_to_otu
          occurrence_key = "#{row['dwc_occurrence_object_type']}:#{row['dwc_occurrence_object_id']}"
          otu_id = @occurrence_to_otu[occurrence_key]

          if otu_id
            tn_data = @taxon_name_data[otu_id]

            if tn_data && tn_data[:cached].present?
              is_valid = [true, 't', 'true', 1, '1'].include?(tn_data[:cached_is_valid])

              if accepted_name_mode == 'replace_with_accepted_name'
                # Replace invalid names with their valid names
                if !is_valid && tn_data[:valid_cached].present?
                  # Replace scientificName with the valid name
                  row['scientificName'] = tn_data[:valid_cached]
                elsif !is_valid
                  # Invalid name with no valid name - skip this row entirely
                  next
                end
                # Valid names stay as-is
              elsif accepted_name_mode == 'accepted_name_usage_id'
                # Store TaxonName data for later acceptedNameUsageID processing
                row['taxon_name_cached'] = tn_data[:cached]
                row['taxon_name_cached_is_valid'] = tn_data[:cached_is_valid]
                row['taxon_name_cached_valid_taxon_name_id'] = tn_data[:cached_valid_taxon_name_id]
              end
            end
          end
        end
        # Process each rank column to extract higher taxa (DwcOccurrence doesn't
        # include columns matching ORDERED_RANKS for speciesGroup ranks, so
        # those are processed below).
        ORDERED_RANKS.each do |rank|
          rank_name = row[rank]
          next if rank_name.nil? || rank_name.strip.empty?

          key = "#{rank}:#{rank_name}"
          next if all_taxa[key] # already have this taxon

          # Build the new taxon row for this higher taxon.
          taxon = row.to_h.dup
          original_rank = taxon['taxonRank']&.downcase
          taxon['scientificName'] = rank_name
          taxon['taxonRank'] = rank
          clear_lower_ranks(taxon, rank, original_rank)

          # Clear taxon_name_ columns ONLY if this is an extracted higher taxon, not a terminal taxon
          # If rank == original_rank, this is a terminal taxon at this rank (e.g., genus-level OTU)
          # and we should preserve its validity data
          if rank != original_rank
            taxon['taxon_name_cached'] = nil
            taxon['taxon_name_cached_is_valid'] = nil
            taxon['taxon_name_cached_valid_taxon_name_id'] = nil
          end

          all_taxa[key] = taxon
        end

        # Also include the terminal taxon (usually species) if it has
        # scientificName.
        if row['scientificName'] && !row['scientificName'].strip.empty?
          rank = row['taxonRank']&.downcase
          next if rank.nil?

          # In synonym mode, use taxon_name_cached (original name) if available
          # Otherwise use scientificName (accepted name or when not in synonym mode)
          name_for_key = row['taxon_name_cached'].presence || row['scientificName']
          key = "#{rank}:#{name_for_key}"
          next if all_taxa[key] # already have this taxon

          # Store the taxon with the original name if in synonym mode
          taxon = row.to_h
          if row['taxon_name_cached'].present?
            taxon['scientificName'] = row['taxon_name_cached']
          end
          all_taxa[key] = taxon

          # If this is an infraspecific taxon (subspecies, variety, etc.),
          # also extract its parent species if not already present
          if self.class.infraspecific_rank_names.include?(rank)
            genus = row['genus']
            specific_epithet = row['specificEpithet']

            if genus.present? && specific_epithet.present?
              # Construct parent species scientificName from binomial
              species_name = "#{genus} #{specific_epithet}"
              species_key = "species:#{species_name}"

              # Only add if we don't already have this species
              unless all_taxa[species_key]
                # Create species taxon by duping the infraspecific row
                species_taxon = row.to_h.dup
                original_rank = species_taxon['taxonRank']&.downcase
                species_taxon['scientificName'] = species_name
                species_taxon['taxonRank'] = 'species'
                clear_lower_ranks(species_taxon, 'species', original_rank)

                # Clear taxon_name_ columns since this is an extracted parent species
                species_taxon['taxon_name_cached'] = nil
                species_taxon['taxon_name_cached_is_valid'] = nil
                species_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

                all_taxa[species_key] = species_taxon
              end
            end
          end
        end
      end

      all_taxa
    end

    # Ensure valid names exist for all synonyms
    # @param all_taxa [Hash] hash of "rank:name" => taxon data
    # @param parsed [CSV::Table] parsed occurrence data (to get TaxonName data)
    # @return [Hash] updated all_taxa with valid names added
    def ensure_valid_names_for_synonyms(all_taxa, parsed)
      # Track valid TaxonName IDs we need to fetch
      valid_taxon_name_ids = Set.new

      # Find all synonyms and collect their valid_taxon_name_ids
      all_taxa.each_value do |taxon|
        # Check if this is a synonym (not valid)
        is_valid = taxon['taxon_name_cached_is_valid']
        # Use !is_valid.nil? to handle false values correctly
        next unless !is_valid.nil? && !['t', 'true', true, 1, '1'].include?(is_valid)

        valid_id = taxon['taxon_name_cached_valid_taxon_name_id']
        valid_taxon_name_ids << valid_id.to_i if valid_id.present?
      end

      return all_taxa if valid_taxon_name_ids.empty?

      # Fetch valid TaxonName records
      valid_taxon_names = ::TaxonName.where(id: valid_taxon_name_ids.to_a).includes(:ancestor_hierarchies)

      # Create taxa for valid names that don't exist yet
      valid_taxon_names.each do |valid_tn|
        rank = valid_tn.rank&.downcase
        next if rank.nil?

        key = "#{rank}:#{valid_tn.cached}"
        next if all_taxa[key] # already exists

        # Find a synonym that points to this valid name to use as template
        # Check both string and integer comparison since the value might be either
        template_taxon = all_taxa.values.find do |t|
          vid = t['taxon_name_cached_valid_taxon_name_id']
          vid.present? && (vid.to_i == valid_tn.id || vid == valid_tn.id.to_s)
        end

        next unless template_taxon

        # Create valid name taxon from template
        valid_taxon = template_taxon.dup
        valid_taxon['scientificName'] = valid_tn.cached
        valid_taxon['taxonRank'] = rank
        valid_taxon['taxon_name_cached'] = valid_tn.cached
        valid_taxon['taxon_name_cached_is_valid'] = 't'
        valid_taxon['taxon_name_cached_valid_taxon_name_id'] = nil

        # Clear lower ranks
        clear_lower_ranks(valid_taxon, rank, template_taxon['taxonRank']&.downcase)

        all_taxa[key] = valid_taxon
      end

      all_taxa
    end

    # Assign sequential taxonIDs and parentNameUsageIDs to all taxa
    # @param all_taxa [Hash] hash of "rank:name" => taxon data
    # @return [Array] [processed_taxa, name_to_id] - processed taxa array and name-to-ID mapping
    def assign_taxon_ids_and_build_hierarchy(all_taxa)
      taxon_id_counter = 1
      name_to_id = {} # "rank:name" → taxonID
      species_binomial_to_id = {} # "genus specificEpithet" → taxonID (for infraspecific taxa lookups)
      processed_taxa = []

      # Batch-fetch all valid TaxonNames upfront to avoid N+1 queries
      valid_taxon_name_cache = {}
      if accepted_name_mode == 'accepted_name_usage_id'
        valid_ids = all_taxa.values
          .filter_map { |t| t['taxon_name_cached_valid_taxon_name_id']&.to_i }
          .uniq

        if valid_ids.any?
          ::TaxonName.where(id: valid_ids).find_each do |tn|
            valid_taxon_name_cache[tn.id] = tn
          end
        end
      end

      # PASS 1: Assign taxonIDs to all taxa and build name_to_id mapping
      # This ensures all taxa have IDs before we try to look up acceptedNameUsageID
      taxa_with_ids = []

      ORDERED_RANKS.each do |rank|
        rank_taxa = all_taxa.select { |k, v| k.start_with?("#{rank}:") }.values
        rank_taxa.sort_by! { |t| t['scientificName'] || '' }

        rank_taxa.each do |taxon|
          sci_name = taxon['scientificName']
          key = "#{rank}:#{sci_name}"
          next if name_to_id[key]

          taxon_id = taxon_id_counter
          taxon_id_counter += 1
          name_to_id[key] = taxon_id

          # For species, also add to binomial lookup
          if rank == 'species'
            genus = taxon['genus']
            specific_epithet = taxon['specificEpithet']
            if genus.present? && specific_epithet.present?
              binomial = "#{genus} #{specific_epithet}"
              species_binomial_to_id[binomial] = taxon_id
            end
          end

          taxa_with_ids << { taxon: taxon, taxon_id: taxon_id, rank: rank, key: key }
        end
      end

      # PASS 2: Build final processed taxa with parent/accepted relationships
      # Now name_to_id is complete, so synonym lookups will work
      taxa_with_ids.each do |item|
        taxon = item[:taxon]
        taxon_id = item[:taxon_id]
        rank = item[:rank]

        parent_id = find_parent_taxon_id_from_columns(taxon, rank, name_to_id, species_binomial_to_id)

        # Determine acceptedNameUsageID and taxonomicStatus
        accepted_name_usage_id = nil
        taxonomic_status = nil

        if accepted_name_mode == 'accepted_name_usage_id'
          is_valid = taxon['taxon_name_cached_is_valid']

          if !is_valid.nil?
            # We have definitive validity data from a terminal TaxonName
            # Check if valid - handle both boolean and string representations
            if [true, 't', 'true', 1, '1'].include?(is_valid)
              # This taxon is marked as valid/accepted
              accepted_name_usage_id = taxon_id
              taxonomic_status = 'accepted'
            else
              # This taxon is marked as invalid (synonym)
              valid_taxon_name_id = taxon['taxon_name_cached_valid_taxon_name_id']
              if valid_taxon_name_id.present?
                valid_tn = valid_taxon_name_cache[valid_taxon_name_id.to_i]
                if valid_tn
                  valid_rank = valid_tn.rank&.downcase
                  valid_key = "#{valid_rank}:#{valid_tn.cached}"
                  accepted_name_usage_id = name_to_id[valid_key]
                end
                taxonomic_status = 'synonym'
              end
            end
          else
            # No validity data (is_valid is nil) - this is an extracted higher taxon from rank columns
            # These represent accepted names because DwcOccurrence builds classification from valid_taxon_name.
            # See Shared::Taxonomy#taxonomy_for_object which uses taxon_name.valid_taxon_name for synonyms,
            # ensuring higher classification always comes from the accepted name's hierarchy, not the synonym's.
            accepted_name_usage_id = taxon_id
            taxonomic_status = 'accepted'
          end
        end

        excluded_fields = ['taxonID', 'id', 'acceptedNameUsageID', 'parentNameUsageID', 'taxon_name_cached', 'taxon_name_cached_is_valid', 'taxon_name_cached_valid_taxon_name_id', 'dwc_occurrence_object_type', 'dwc_occurrence_object_id']
        excluded_fields << 'taxonomicStatus' if accepted_name_mode == 'accepted_name_usage_id'

        # Build base fields
        processed_taxon = {
          'id' => taxon_id,
          'taxonID' => taxon_id,
          'parentNameUsageID' => parent_id
        }

        # Only add acceptedNameUsageID and taxonomicStatus in accepted_name_usage_id mode
        if accepted_name_mode == 'accepted_name_usage_id'
          processed_taxon['acceptedNameUsageID'] = accepted_name_usage_id
          processed_taxon['taxonomicStatus'] = taxonomic_status
        end

        processed_taxon.merge!(taxon.except(*excluded_fields))

        processed_taxa << processed_taxon
      end

      [processed_taxa, name_to_id]
    end

    # Clear columns for ranks lower/higher than the current rank and recompute higherClassification
    # @param taxon [Hash] the taxon data hash to modify
    # @param current_rank [String] the rank being extracted
    # @param original_rank [String] the original taxonRank before extraction
    def clear_lower_ranks(taxon, current_rank, original_rank = nil)
      current_id = ORDERED_RANKS.index(current_rank)
      return unless current_id

      # If extracting a taxon at the same rank as the original row, keep all fields as-is
      # (this happens when the terminal taxon appears in a rank column, e.g., monotypic genus)
      return if current_rank == original_rank

      # Clear lower rank columns
      ORDERED_RANKS[(current_id + 1)..-1].each do |lower_rank|
        taxon[lower_rank] = nil
      end

      # Fields to keep for extracted taxa (rank columns + core fields + epithet fields based on rank)
      rank_columns = ORDERED_RANKS.map(&:to_s)
      fields_to_keep = rank_columns + ['scientificName', 'taxonRank', 'nomenclaturalCode']

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

      # Clear all other taxon-specific fields from the original terminal taxon
      ::DwcOccurrence::ColumnSets::CHECKLIST_TAXON_EXTENSION_COLUMNS.keys.each do |field|
        field_str = field.to_s
        # Convert dwcClass to 'class' for comparison
        field_str = 'class' if field == :dwcClass
        taxon[field_str] = nil unless fields_to_keep.include?(field_str)
      end

      # Recompute higherClassification for this rank from higher rank columns
      higher_ranks = ORDERED_RANKS[0...current_id]
      classification_parts = higher_ranks.map { |r| taxon[r] }.compact.reject(&:empty?)
      taxon['higherClassification'] = classification_parts.empty? ? nil : classification_parts.join(Export::Dwca::DELIMITER)
    end

    # Get all infraspecific rank names (species-level ranks excluding "species" itself)
    def self.infraspecific_rank_names
      @infraspecific_rank_names ||= begin
        iczn = ::NomenclaturalRank::Iczn::SpeciesGroup.ordered_ranks.map(&:rank_name)
        icn = ::NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.ordered_ranks.map(&:rank_name)
        icnp = ::NomenclaturalRank::Icnp::SpeciesGroup.ordered_ranks.map(&:rank_name)

        all_species_ranks = (iczn + icn + icnp).uniq
        all_species_ranks - ['species']
      end
    end

    # Find the taxonID of the parent taxon by looking at rank columns or
    # constructing parent name.
    # @param taxon [Hash] the current taxon's data
    # @param current_rank [String] the rank of the current taxon
    # @param name_to_id [Hash] mapping of "rank:name" → taxonID
    # @param species_binomial_to_id [Hash] mapping of "genus specificEpithet" → taxonID for species lookups
    # @return [Integer, nil] the parent's taxonID or nil if no parent
    def find_parent_taxon_id_from_columns(taxon, current_rank, name_to_id, species_binomial_to_id = {})
      current_rank_index = ORDERED_RANKS.index(current_rank)
      return nil if current_rank_index.nil? || current_rank_index == 0

      # Special handling for infraspecific ranks (subspecies, variety, form,
      # etc.): these need to link to their parent species.
      if self.class.infraspecific_rank_names.include?(current_rank)
        # Construct binomial from genus + specificEpithet
        genus = taxon['genus']
        specific_epithet = taxon['specificEpithet']

        if genus.present? && specific_epithet.present?
          binomial = "#{genus} #{specific_epithet}"
          parent_id = species_binomial_to_id[binomial]

          return parent_id if parent_id
        end
      else # species and higher ranks
        (current_rank_index - 1).downto(0) do |i|
          parent_rank = ORDERED_RANKS[i]
          parent_name = taxon[parent_rank]

          if parent_name && !parent_name.strip.empty?
            parent_key = "#{parent_rank}:#{parent_name}"
            parent_id = name_to_id[parent_key]

            return parent_id if parent_id
          end
        end
      end

      nil
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
          # TODO: rowType
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.tsv'
            }
            xml.id(index: 0) # Must be named id
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i + 1, term: h)
              else
                xml.field(index: i + 1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }

          # Species Distribution extension
          if distribution_extension
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\\n', fieldsTerminatedBy: '\\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.gbif.org/terms/1.0/Distribution') {
              xml.files {
                xml.location 'distribution.tsv'
              }
              Export::CSV::Dwc::Extension::SpeciesDistribution::HEADERS_NAMESPACES.each_with_index do |n, i|
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
              Export::CSV::Dwc::Extension::References::HEADERS_NAMESPACES.each_with_index do |n, i|
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
              Export::CSV::Dwc::Extension::TypesAndSpecimen::HEADERS_NAMESPACES.each_with_index do |n, i|
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
              Export::CSV::Dwc::Extension::VernacularName::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First vernacular_name column (id) should have namespace '', got '#{n}'")
                  xml.id(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # TODO: Add additional checklist-specific extensions here (e.g., taxon descriptions, etc.)
        }
      end

      @meta.write(builder.to_xml)
      @meta.flush
      @meta.rewind
      @meta
    end

    # @return [Tempfile, nil]
    #   Species distribution extension data from AssertedDistribution records
    def distribution_extension_tmp
      return nil unless distribution_extension
      @distribution_extension_tmp = Tempfile.new('distribution.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_to_id mapping if not already done
        csv unless taxon_name_to_id

        # Only export distribution extension for AssertedDistribution-based DwcOccurrence records
        distribution_scope = core_occurrence_scope.where(dwc_occurrence_object_type: 'AssertedDistribution')

        content = Export::CSV::Dwc::Extension::SpeciesDistribution.csv(distribution_scope, taxon_name_to_id)
      end

      @distribution_extension_tmp.write(content)
      @distribution_extension_tmp.flush
      @distribution_extension_tmp.rewind
      @distribution_extension_tmp
    end

    # @return [Tempfile, nil]
    #   Literature references extension data
    def references_extension_tmp
      return nil unless references_extension
      @references_extension_tmp = Tempfile.new('references.tsv')

      content = nil
      if no_records?
        content = "\n"
      else
        # Generate core CSV first to populate taxon_name_to_id mapping if not already done
        csv unless taxon_name_to_id

        # Export references for all DwcOccurrence records
        # (only AssertedDistribution records have associatedReferences populated)
        content = Export::CSV::Dwc::Extension::References.csv(core_occurrence_scope, taxon_name_to_id)
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
        # Generate core CSV first to populate taxon_name_to_id mapping if not already done
        csv unless taxon_name_to_id

        # Export types and specimen for CollectionObject DwcOccurrence records
        # (only CollectionObject records with typeStatus populated)
        content = Export::CSV::Dwc::Extension::TypesAndSpecimen.csv(core_occurrence_scope, taxon_name_to_id)
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
        # Generate core CSV first to populate taxon_name_to_id mapping if not already done
        csv unless taxon_name_to_id

        # Export vernacular names from CommonName records
        # Note: NOT using DwcOccurrence (vernacularName field not populated)
        content = Export::CSV::Dwc::Extension::VernacularName.csv(core_otu_scope_params, taxon_name_to_id)
      end

      @vernacular_name_extension_tmp.write(content)
      @vernacular_name_extension_tmp.flush
      @vernacular_name_extension_tmp.rewind
      @vernacular_name_extension_tmp
    end

    def build_zip
      t = Tempfile.new(filename)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, Zip::File::CREATE) do |zip|
        zip.add('data.tsv', data_file.path)

        # Add extensions
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
      if @zipfile.nil?
        @zipfile = build_zip
      end

      @zipfile
    end

    # @return [String]
    # the name of zipfile
    def filename
      @filename ||= "dwc_checklist_#{DateTime.now}.zip"
      @filename
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

      # For now, just the main data file
      # Later we can add extensions like occurrence_data does
      join_data = [data_file]

      # TODO: Add extension support here (biological_associations, media, etc.)

      # Combine all data files
      join_data.each_with_index do |file, i|
        file.rewind
        if i == 0
          @all_data.write(file.read)
        else
          # Skip header line for subsequent files
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