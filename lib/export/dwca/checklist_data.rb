require 'zip'

module Export::Dwca

  class ChecklistData

    # Extension constants - callers pass array of these to specify which extensions to include
    DISTRIBUTION_EXTENSION = :distribution

    # @return [Hash] of Otu query params
    #  Required.
    attr_accessor :core_otu_scope

    # @return [Scope] of DwcOccurrence
    # Derived from core_otu_scope
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

    # @return [Array<Symbol>] list of extensions to include
    attr_accessor :extensions

    def initialize(core_scope: nil, extensions: [])
      @core_otu_scope = core_scope
      @extensions = extensions

      @core_occurrence_scope = ::Queries::DwcOccurrence::Filter.new(
        otu_query: core_scope
      ).all

      # Set extension flags based on requested extensions
      @distribution_extension = extensions.include?(DISTRIBUTION_EXTENSION)
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

      # Get raw occurrence data with all taxonomy columns.
      raw_csv = ::Export::CSV.generate_csv(
        core_occurrence_scope.computed_checklist_columns,
        exclude_columns: ::DwcOccurrence::EXCLUDED_CHECKLIST_COLUMNS,
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
      processed_taxa, name_to_id = assign_taxon_ids_and_build_hierarchy(all_taxa)

      # Store the name-to-ID mapping for extensions to use
      @taxon_name_to_id = name_to_id

      output_headers = processed_taxa.first&.keys || []

      CSV.generate(col_sep: "\t") do |csv|
        csv << output_headers

        processed_taxa.each do |taxon|
          csv << taxon.values
        end
      end
    end

    # Extract all unique taxa from occurrence data.
    # @param parsed [CSV::Table] parsed occurrence data
    # @return [Hash] hash of "rank:name" => taxon data
    def extract_unique_taxa(parsed)
      all_taxa = {}

      parsed.each do |row|
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
          taxon['scientificName'] = rank_name
          taxon['taxonRank'] = rank
          clear_lower_ranks(taxon, rank)

          all_taxa[key] = taxon
        end

        # Also include the terminal taxon (usually species) if it has
        # scientificName.
        if row['scientificName'] && !row['scientificName'].strip.empty?
          rank = row['taxonRank']&.downcase
          next if rank.nil?

          key = "#{rank}:#{row['scientificName']}"
          next if all_taxa[key] # already have this taxon

          all_taxa[key] = row.to_h
        end
      end

      all_taxa
    end

    # Assign sequential taxonIDs and parentNameUsageIDs to all taxa
    # @param all_taxa [Hash] hash of "rank:name" => taxon data
    # @return [Array] [processed_taxa, name_to_id] - processed taxa array and name-to-ID mapping
    def assign_taxon_ids_and_build_hierarchy(all_taxa)
      taxon_id_counter = 1
      name_to_id = {} # "rank:name" → taxonID
      processed_taxa = []

      # Process ranks from highest to lowest
      ORDERED_RANKS.each do |rank|
        # Find all taxa at this rank
        rank_taxa = all_taxa.select { |k, v| k.start_with?("#{rank}:") }.values

        # Sort alphabetically by scientificName
        rank_taxa.sort_by! { |t| t['scientificName'] || '' }

        rank_taxa.each do |taxon|
          sci_name = taxon['scientificName']
          key = "#{rank}:#{sci_name}"

          # Skip if already processed
          next if name_to_id[key]

          # Assign new taxonID
          taxon_id = taxon_id_counter
          taxon_id_counter += 1
          name_to_id[key] = taxon_id

          # Find parent taxonID by looking at parent rank column
          parent_id = find_parent_taxon_id_from_columns(taxon, rank, name_to_id)

          # Store processed taxon with new IDs.
          # Key order determines final CSV column order.
          # id column is required for DwC-A star joins with extensions.
          processed_taxon = {
            'id' => taxon_id,
            'taxonID' => taxon_id,
            'parentNameUsageID' => parent_id
          }.merge(taxon.except('taxonID', 'id'))

          processed_taxa << processed_taxon
        end
      end

      [processed_taxa, name_to_id]
    end

    # Clear columns for ranks lower than the current rank
    def clear_lower_ranks(taxon, current_rank)
      current_id = ORDERED_RANKS.index(current_rank)
      return unless current_id

      ORDERED_RANKS[(current_id + 1)..-1].each do |lower_rank|
        taxon[lower_rank] = nil
      end

      # Handle epithet fields based on rank:
      # - Species: keep specificEpithet, clear infraspecificEpithet
      # - Infraspecific (subspecies, variety, form, etc.): keep both epithet fields
      # - Higher ranks (genus, family, etc.): clear both epithet fields
      if current_rank == 'species'
        taxon['infraspecificEpithet'] = nil
      elsif !self.class.infraspecific_rank_names.include?(current_rank)
        taxon['specificEpithet'] = nil
        taxon['infraspecificEpithet'] = nil
      end
      # else: infraspecific rank, keep both epithet fields
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
    # @return [Integer, nil] the parent's taxonID or nil if no parent
    def find_parent_taxon_id_from_columns(taxon, current_rank, name_to_id)
      current_rank_index = ORDERED_RANKS.index(current_rank)
      return nil if current_rank_index.nil? || current_rank_index == 0

      # Special handling for infraspecific ranks (subspecies, variety, form,
      # etc.): these need to link to their parent species, which is constructed
      # from genus + specificEpithet.
      if self.class.infraspecific_rank_names.include?(current_rank)
        genus = taxon['genus']
        specific_epithet = taxon['specificEpithet']

        if genus.present? && specific_epithet.present?
          # Construct parent species scientificName
          species_name = "#{genus} #{specific_epithet}"
          species_key = "species:#{species_name}"
          parent_id = name_to_id[species_key]

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

          # TODO: Add additional checklist-specific extensions here (e.g., vernacular names, taxon descriptions, etc.)
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

    def build_zip
      t = Tempfile.new(filename)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, Zip::File::CREATE) do |zip|
        zip.add('data.tsv', data_file.path)

        # Add extensions
        zip.add('distribution.tsv', distribution_extension_tmp.path) if distribution_extension

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

      eml.close if eml
      eml.unlink if eml

      meta.close if meta
      meta.unlink if meta

      true
    end
  end
end