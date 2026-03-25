require 'zip'

module Export::Dwca::Checklist
  class Data

    # Available extensions.
    DESCRIPTION_EXTENSION = :description
    DISTRIBUTION_EXTENSION = :distribution
    REFERENCES_EXTENSION = :references
    TYPES_AND_SPECIMEN_EXTENSION = :types_and_specimen
    VERNACULAR_NAME_EXTENSION = :vernacular_name

    CHECKLIST_EXTENSION_OPTIONS = [
      { value: DESCRIPTION_EXTENSION, displayed_in_gbif: true },
      { value: DISTRIBUTION_EXTENSION, displayed_in_gbif: true },
      { value: REFERENCES_EXTENSION, displayed_in_gbif: false },
      { value: TYPES_AND_SPECIMEN_EXTENSION, displayed_in_gbif: false },
      { value: VERNACULAR_NAME_EXTENSION, displayed_in_gbif: true }
    ].freeze

    # Accepted name mode values.
    REPLACE_WITH_ACCEPTED_NAME = 'replace_with_accepted_name'
    ACCEPTED_NAME_USAGE_ID = 'accepted_name_usage_id'

    # Maps TaxonNameRelationship type strings to GBIF 2022 taxonomic status
    # vocabulary terms. Checked in order; first match wins.
    # https://rs.gbif.org/vocabulary/gbif/taxonomic_status_2022-02-02.xml
    GBIF_TAXONOMIC_STATUS_FROM_RELATIONSHIP = [
      [/Misapplication/,                             'misapplied'        ],
      [/Synonym::Objective|Synonym::Homotypic/,      'homotypicSynonym'  ],
      [/Synonym::Subjective|Synonym::Heterotypic/,   'heterotypicSynonym'],
      [/Synonym|Invalidating|Unaccepting/,           'synonym'           ],
    ].freeze

    # @param relationship_type [String, nil] value of taxon_name_relationships.type
    # @return [String, nil] GBIF 2022 taxonomic status term
    def self.gbif_taxonomic_status_for(relationship_type)
      return nil if relationship_type.nil?
      GBIF_TAXONOMIC_STATUS_FROM_RELATIONSHIP.each do |pattern, status|
        return status if relationship_type.match?(pattern)
      end
      nil
    end

    # @param relationship_types [Array<String>] values of taxon_name_relationships.type
    # @return [String, nil] highest-priority GBIF 2022 taxonomic status term
    def self.gbif_taxonomic_status_from_types(relationship_types)
      _, status = GBIF_TAXONOMIC_STATUS_FROM_RELATIONSHIP.find { |pattern, _|
        relationship_types.any? { |t| t.match?(pattern) }
      }
      status
    end

    ACCEPTED_NAME_MODE_OPTIONS = [
      REPLACE_WITH_ACCEPTED_NAME,
      ACCEPTED_NAME_USAGE_ID
    ].freeze

    # Keys are dwc_occurrence columns, values are DwC Taxon Extension columns:
    # https://rs.gbif.org/core/dwc_taxon_2024-02-19.xml
    CHECKLIST_TAXON_EXTENSION_COLUMNS = {
      scientificName: :scientificName,
      taxonRank: :taxonRank,
      acceptedNameUsage: :acceptedNameUsage,
      parentNameUsage: :parentNameUsage,
      originalNameUsage: :originalNameUsage,
      nameAccordingTo: :nameAccordingTo,
      namePublishedIn: :namePublishedIn,
      namePublishedInYear: :namePublishedInYear,
      higherClassification: :higherClassification,
      kingdom: :kingdom,
      phylum: :phylum,
      dwcClass: :class,  # Note: column is dwcClass, DwC Taxon field is 'class'
      order: :order,
      superfamily: :superfamily,
      family: :family,
      subfamily: :subfamily,
      tribe: :tribe,
      subtribe: :subtribe,
      genus: :genus,
      subgenus: :subgenus,
      specificEpithet: :specificEpithet,
      infraspecificEpithet: :infraspecificEpithet,
      verbatimTaxonRank: :verbatimTaxonRank,
      scientificNameAuthorship: :scientificNameAuthorship,
      vernacularName: :vernacularName,
      nomenclaturalCode: :nomenclaturalCode,
      taxonomicStatus: :taxonomicStatus,
      nomenclaturalStatus: :nomenclaturalStatus,
      taxonRemarks: :taxonRemarks
    }.freeze

    # Namespace URIs for checklist taxon core fields.
    # Maps DwC Taxon field names to their full namespace URIs.
    CHECKLIST_TAXON_NAMESPACES = {
      taxonID: 'http://rs.tdwg.org/dwc/terms/taxonID',
      scientificName: 'http://rs.tdwg.org/dwc/terms/scientificName',
      taxonRank: 'http://rs.tdwg.org/dwc/terms/taxonRank',
      acceptedNameUsage: 'http://rs.tdwg.org/dwc/terms/acceptedNameUsage',
      acceptedNameUsageID: 'http://rs.tdwg.org/dwc/terms/acceptedNameUsageID',
      parentNameUsage: 'http://rs.tdwg.org/dwc/terms/parentNameUsage',
      parentNameUsageID: 'http://rs.tdwg.org/dwc/terms/parentNameUsageID',
      originalNameUsage: 'http://rs.tdwg.org/dwc/terms/originalNameUsage',
      nameAccordingTo: 'http://rs.tdwg.org/dwc/terms/nameAccordingTo',
      namePublishedIn: 'http://rs.tdwg.org/dwc/terms/namePublishedIn',
      namePublishedInYear: 'http://rs.tdwg.org/dwc/terms/namePublishedInYear',
      higherClassification: 'http://rs.tdwg.org/dwc/terms/higherClassification',
      kingdom: 'http://rs.tdwg.org/dwc/terms/kingdom',
      phylum: 'http://rs.tdwg.org/dwc/terms/phylum',
      class: 'http://rs.tdwg.org/dwc/terms/class',
      order: 'http://rs.tdwg.org/dwc/terms/order',
      superfamily: 'http://rs.tdwg.org/dwc/terms/superfamily',
      family: 'http://rs.tdwg.org/dwc/terms/family',
      subfamily: 'http://rs.tdwg.org/dwc/terms/subfamily',
      tribe: 'http://rs.tdwg.org/dwc/terms/tribe',
      subtribe: 'http://rs.tdwg.org/dwc/terms/subtribe',
      genus: 'http://rs.tdwg.org/dwc/terms/genus',
      subgenus: 'http://rs.tdwg.org/dwc/terms/subgenus',
      specificEpithet: 'http://rs.tdwg.org/dwc/terms/specificEpithet',
      infraspecificEpithet: 'http://rs.tdwg.org/dwc/terms/infraspecificEpithet',
      verbatimTaxonRank: 'http://rs.tdwg.org/dwc/terms/verbatimTaxonRank',
      scientificNameAuthorship: 'http://rs.tdwg.org/dwc/terms/scientificNameAuthorship',
      vernacularName: 'http://rs.tdwg.org/dwc/terms/vernacularName',
      nomenclaturalCode: 'http://rs.tdwg.org/dwc/terms/nomenclaturalCode',
      taxonomicStatus: 'http://rs.tdwg.org/dwc/terms/taxonomicStatus',
      nomenclaturalStatus: 'http://rs.tdwg.org/dwc/terms/nomenclaturalStatus',
      taxonRemarks: 'http://rs.tdwg.org/dwc/terms/taxonRemarks'
    }.freeze

    # Header converter for checklist exports (Taxon core).
    # Converts dwc_occurrence column names to DwC Taxon extension field names.
    CSV::HeaderConverters[:checklist_headers] = lambda do |field|
      d = CHECKLIST_TAXON_EXTENSION_COLUMNS[field.to_sym]
      d ? d.to_s : field
    end

    # @return [Array] of rank strings in hierarchical order (highest to lowest).
    # Includes both column-based ranks (kingdom, phylum, etc.) and all possible
    # taxonRank values that may appear for terminal taxa (species, subspecies,
    # variety, form, etc.).
    def self.ordered_ranks
      # Get rank columns available in DwcOccurrence (mapped to DwC field names).
      dwc_rank_columns = CHECKLIST_TAXON_EXTENSION_COLUMNS.keys
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

    # @return [Boolean] whether to include description extension
    attr_accessor :description_extension

    # @return [Boolean] whether to include distribution extension
    attr_accessor :species_distribution_extension

    # @return [Boolean] whether to include references extension
    attr_accessor :references_extension

    # @return [Boolean] whether to include types and specimen extension
    attr_accessor :types_and_specimen_extension

    # @return [Boolean] whether to include vernacular name extension
    attr_accessor :vernacular_name_extension

    # @return [Array<Integer>] ordered list of topic IDs for description extension
    attr_accessor :description_topics

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
      accepted_name_mode: 'replace_with_accepted_name',
      description_topics: []
    )
      @accepted_name_mode = accepted_name_mode

      @core_otu_scope_params = (core_otu_scope_params&.to_h || {}).deep_symbolize_keys

      @extensions = extensions
      @description_topics = description_topics

      # Strip pagination/meta params — they are not OTU filter criteria and
      # would trigger the otu_query subquery chain unnecessarily.
      otu_filter_criteria = @core_otu_scope_params
        .except(:per, :page, :paginate, :extend)

      # When no actual OTU filter criteria remain, skip the otu_query subquery
      # chain entirely — it would build complex nested CTEs for "all OTUs in
      # project" that are slow and unnecessary.
      # An empty filter simply returns all project DwcOccurrences directly.
      @core_occurrence_scope = if otu_filter_criteria.present?
        ::Queries::DwcOccurrence::Filter.new(
          otu_query: otu_filter_criteria
        ).all
      else
        ::Queries::DwcOccurrence::Filter.new({}).all
      end

      @description_extension = extensions.include?(DESCRIPTION_EXTENSION)
      @species_distribution_extension = extensions.include?(DISTRIBUTION_EXTENSION)
      @references_extension = extensions.include?(REFERENCES_EXTENSION)
      @types_and_specimen_extension = extensions.include?(TYPES_AND_SPECIMEN_EXTENSION)
      @vernacular_name_extension = extensions.include?(VERNACULAR_NAME_EXTENSION)
    end

    # @return [Array] use the temporarily written, and refined, CSV file to read
    #   off the existing headers so we can use them in writing meta.yml.
    #   Non-standard DwC colums are handled elsewhere.
    def meta_fields
      return [] if no_records?

      h = File.open(data_file, &:gets)&.strip&.split("\t")
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
    #   taxon) with OTU UUID taxonIDs and parentNameUsageID relationships -
    #   see https://ipt.gbif.org/manual/en/ipt/latest/best-practices-checklists#normalized-classifications-parentchild
    def csv
      return "\n" if no_records?

      # We need dwc_occurrence_object_type/id for OTU lookups.
      # Don't exclude them initially - we'll remove them after processing.
      excluded_columns = excluded_checklist_columns - [:dwc_occurrence_object_type, :dwc_occurrence_object_id]

      # Get raw occurrence data with all taxonomy columns.
      raw_csv = ::Export::CSV.generate_csv(
        core_occurrence_scope.select(target_checklist_columns),
        exclude_columns: excluded_columns,
        column_order: CHECKLIST_TAXON_EXTENSION_COLUMNS.keys,
        header_converters: [:checklist_headers]
      )

      # Return normalized taxonomy with OTU UUID taxonIDs.
      normalize_occurrence_csv(raw_csv)
    end

    # Normalize taxonomy: deduplicate, assign OTU UUID taxonIDs, add
    # parentNameUsageID.
    # @param raw_csv [String] CSV with one row per occurrence
    # @return [String] CSV with one row per unique taxon
    def normalize_occurrence_csv(raw_csv)
      normalizer = OccurrenceNormalizer.new(
        raw_csv: raw_csv,
        accepted_name_mode: accepted_name_mode,
        otu_to_taxon_name_data: otu_to_taxon_name_data,
        occurrence_to_otu: occurrence_to_otu
      )

      csv_output, taxon_name_id_to_taxon_id = normalizer.normalize

      # Store mapping for extensions to use
      @taxon_name_id_to_taxon_id = taxon_name_id_to_taxon_id

      csv_output
    end

    # Fetch TaxonName data by unique OTU (not by occurrence).
    # @return [Hash] otu_id => { cached:, cached_is_valid:, cached_valid_taxon_name_id: }
    def otu_to_taxon_name_data
      return @otu_to_taxon_name_data if @otu_to_taxon_name_data

      # Fetch TaxonName data for these OTUs in a single query.
      # Also fetch the valid taxon name's cached value for synonyms.
      @otu_to_taxon_name_data = ::Otu
        .where(id: core_occurrence_scope.where.not(otu_id: nil).select(:otu_id))
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
            cached_valid_taxon_name_id: row[4]&.to_i,
            valid_cached: row[5]
          }
        end

      # Enrich invalid names with their GBIF 2022 taxonomic status derived from
      # the TaxonNameRelationship that makes each name a synonym/misapplication.
      invalid_tn_ids = @otu_to_taxon_name_data.values
        .select { |d| d[:cached_is_valid] == false }
        .map { |d| d[:id] }

      if invalid_tn_ids.any?
        tn_id_to_types = ::TaxonNameRelationship
          .where(subject_taxon_name_id: invalid_tn_ids)
          .pluck(:subject_taxon_name_id, :type)
          .each_with_object(Hash.new { |h, k| h[k] = [] }) { |(tn_id, type), h|
            h[tn_id] << type
          }

        tn_id_to_status = tn_id_to_types.transform_values { |types|
          self.class.gbif_taxonomic_status_from_types(types)
        }

        @otu_to_taxon_name_data.each_value do |data|
          data[:gbif_taxonomic_status] = tn_id_to_status[data[:id]]
        end
      end

      @otu_to_taxon_name_data
    end

    # Build mapping from occurrence to OTU ID
    # @return [Hash] "dwc_occurrence_object_type:dwc_occurrence_object_id" => otu_id
    def occurrence_to_otu
      return @occurrence_to_otu if @occurrence_to_otu

      @occurrence_to_otu = core_occurrence_scope
        .pluck(:dwc_occurrence_object_type, :dwc_occurrence_object_id, :otu_id)
        .to_h { |type, id, otu_id| ["#{type}:#{id}", otu_id] }
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

    # Helper to add extension XML to meta.xml
    # @param xml [Nokogiri::XML::Builder] XML builder
    # @param extension_module [Module] extension module with HEADERS_NAMESPACES constant
    # @param file_location [String] filename in the archive
    # @param row_type [String] DwC rowType URI
    # @param extension_name [String] name for error messages
    def add_extension_to_meta(xml, extension_module:, file_location:, row_type:, extension_name:)
      xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t',
                    fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType: row_type) {
        xml.files {
          xml.location file_location
        }
        extension_module::HEADERS_NAMESPACES.each_with_index do |n, i|
          if i == 0
            n == '' || (raise TaxonWorks::Error, "First #{extension_name} column (id) should have namespace '', got '#{n}'")
            xml.id(index: 0)
          else
            xml.field(index: i, term: n)
          end
        end
      }
    end

    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          # Core
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Taxon') {
            xml.files {
              xml.location 'data.tsv'
            }
            xml.id(index: 0) # Must be named id
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i + 1, term: h)
              else
                xml.field(index: i + 1,
                   term: CHECKLIST_TAXON_NAMESPACES[h.to_sym])
              end
            end
          }

          # Species Distribution extension
          if species_distribution_extension
            add_extension_to_meta(xml,
              extension_module: Export::CSV::Dwc::Extension::Checklist::SpeciesDistribution,
              file_location: 'species_distribution.tsv',
              row_type: 'http://rs.gbif.org/terms/1.0/Distribution',
              extension_name: 'species_distribution')
          end

          # Literature References extension
          if references_extension
            add_extension_to_meta(xml,
              extension_module: Export::CSV::Dwc::Extension::Checklist::Reference,
              file_location: 'references.tsv',
              row_type: 'http://rs.gbif.org/terms/1.0/Reference',
              extension_name: 'references')
          end

          # Types and Specimen extension
          if types_and_specimen_extension
            add_extension_to_meta(xml,
              extension_module: Export::CSV::Dwc::Extension::Checklist::TypesAndSpecimen,
              file_location: 'types_and_specimen.tsv',
              row_type: 'http://rs.gbif.org/terms/1.0/TypesAndSpecimen',
              extension_name: 'types_and_specimen')
          end

          # Vernacular Name extension
          if vernacular_name_extension
            add_extension_to_meta(xml,
              extension_module: Export::CSV::Dwc::Extension::Checklist::VernacularName,
              file_location: 'vernacular_name.tsv',
              row_type: 'http://rs.gbif.org/terms/1.0/VernacularName',
              extension_name: 'vernacular_name')
          end

          # Description extension
          if description_extension
            add_extension_to_meta(xml,
              extension_module: Export::CSV::Dwc::Extension::Checklist::Description,
              file_location: 'description.tsv',
              row_type: 'http://rs.gbif.org/terms/1.0/Description',
              extension_name: 'description')
          end
        }
      end

      @meta.write(builder.to_xml)
      @meta.flush
      @meta.rewind
      @meta
    end

    # Helper to generate extension tempfiles
    # @param extension_name [String] name of extension (e.g., 'species_distribution')
    # @param scope [ActiveRecord::Relation, Hash] scope to pass to extension's csv method
    # @return [Tempfile, nil]
    def generate_extension_tmp(extension_name, scope: core_occurrence_scope)
      # Check if extension is enabled
      return nil unless send("#{extension_name}_extension")

      tempfile = Tempfile.new("#{extension_name}.tsv")

      if no_records?
        content = "\n"
      else
        csv unless taxon_name_id_to_taxon_id

        # Build module name from extension_name (e.g., 'species_distribution' -> 'SpeciesDistribution')
        extension_module = "Export::CSV::Dwc::Extension::Checklist::#{extension_name.classify}".constantize

        content = extension_module.csv(
          scope,
          taxon_name_id_to_taxon_id,
          accepted_name_mode: accepted_name_mode
        )
      end

      tempfile.write(content)
      tempfile.flush
      tempfile.rewind

      instance_variable_set("@#{extension_name}_extension_tmp", tempfile)
      tempfile
    end

    # @return [Tempfile, nil]
    #   Species distribution extension data from AssertedDistribution records.
    def species_distribution_extension_tmp
      scope = core_occurrence_scope.where(dwc_occurrence_object_type: 'AssertedDistribution')
      generate_extension_tmp('species_distribution', scope: scope)
    end

    # @return [Tempfile, nil]
    #   Literature references extension data.
    def references_extension_tmp
      generate_extension_tmp('references')
    end

    def types_and_specimen_extension_tmp
      generate_extension_tmp('types_and_specimen')
    end

    def vernacular_name_extension_tmp
      generate_extension_tmp('vernacular_name', scope: core_otu_scope_params)
    end

    def description_extension_tmp
      return nil unless description_extension

      tempfile = Tempfile.new('description.tsv')

      if no_records?
        content = "\n"
      else
        csv unless taxon_name_id_to_taxon_id

        content = Export::CSV::Dwc::Extension::Checklist::Description.csv(
          core_otu_scope_params,
          taxon_name_id_to_taxon_id,
          accepted_name_mode: accepted_name_mode,
          description_topics: description_topics
        )
      end

      tempfile.write(content)
      tempfile.flush
      tempfile.rewind

      @description_extension_tmp = tempfile
      tempfile
    end

    def build_zip
      t = Tempfile.new(zipfile_name)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, create: true) do |zip|
        zip.add('data.tsv', data_file.path)

        zip.add('description.tsv', description_extension_tmp.path) if description_extension
        zip.add('species_distribution.tsv', species_distribution_extension_tmp.path) if species_distribution_extension
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
      @zipfile_name ||= "dwc_checklist_#{Time.current}.zip"
      @zipfile_name
    end


    # @param download [a Download]
    def package_download(download)
      p = zipfile.path

      record_count = taxon_name_id_to_taxon_id&.size || 0

      if download.persisted?
        download.update_columns(total_records: record_count)
      else
        download.total_records = record_count
      end

      # This doesn't touch the db (source_file_path is an instance var).
      download.update!(source_file_path: p) # triggers save_file callback
    end

    # Cleanup temporary files
    def cleanup
      zipfile&.close
      zipfile&.unlink

      data_file&.close
      data_file&.unlink

      @description_extension_tmp&.close
      @description_extension_tmp&.unlink

      @species_distribution_extension_tmp&.close
      @species_distribution_extension_tmp&.unlink

      @references_extension_tmp&.close
      @references_extension_tmp&.unlink

      @types_and_specimen_extension_tmp&.close
      @types_and_specimen_extension_tmp&.unlink

      @vernacular_name_extension_tmp&.close
      @vernacular_name_extension_tmp&.unlink

      eml&.close
      eml&.unlink

      meta&.close
      meta&.unlink

      true
    end

    private

    # @return [Array] of symbols
    #   Columns to select from dwc_occurrences for checklist exports.
    def target_checklist_columns
      [
       :id,
       :dwc_occurrence_object_id, # !! We don't want this, but need it in joins, it is removed in trim via excluded_checklist_columns below
       :dwc_occurrence_object_type, # !! ^
      ] + CHECKLIST_TAXON_EXTENSION_COLUMNS.keys
    end

    # @return [Array] of symbols
    #   Columns to exclude from dwc_occurrences for checklist exports.
    def excluded_checklist_columns
      (::DwcOccurrence.columns.collect{ |c| c.name.to_sym } -
        (
          CHECKLIST_TAXON_EXTENSION_COLUMNS.keys -
            [:dwc_occurrence_object_id, :dwc_occurrence_object_type]
        )
      )
    end

  end
end
