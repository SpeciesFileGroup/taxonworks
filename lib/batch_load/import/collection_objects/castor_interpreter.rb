module BatchLoad
  class Import::CollectionObjects::CastorInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      @collection_objects = {}
      super(**args)
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_collection_objects
      # GenBank           GBK
      # DRMLabVoucher     DRMLV
      # DRMDNAVoucher     DRMDNA
      namespace_genbank = Namespace.find_by(name: 'GenBank')
      namespace_drm_lab_voucher = Namespace.find_by(name: 'DRMLabVoucher')
      namespace_drm_dna_voucher = Namespace.find_by(name: 'DRMDNAVoucher')

      drm_lab_voucher_texts = {}

      @total_data_lines = 0
      i = 0

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collection_object] = []
        parse_result.objects[:extract] = []
        parse_result.objects[:taxon_determination] = []

        @processed_rows[i] = parse_result

        # Only accept records from DRM to keep things simple for now
        next if row['locality_database'] != 'DRM'

        begin # processing
          # Text for sample code identifiers for both extract and specimen
          sample_code_identifier_text = "#{row['sample_code_prefix']}#{row['sample_code']}"

          # Extract identifiers
          extract_identifier_genbank = {
            namespace: namespace_genbank,
            type: 'Identifier::Local::CatalogNumber',
            identifier: sample_code_identifier_text
          }

          extract_identifiers = []
          extract_identifiers.push(extract_identifier_genbank) if sample_code_identifier_text.present?

          extract_attributes = {
            verbatim_anatomical_origin: row['taxon_name'],
            year_made: 2015,
            month_made: 10,
            day_made: 10,
            identifiers_attributes: extract_identifiers
          }

          extract = Extract.new(extract_attributes)

          parse_result.objects[:extract].push(extract)

          # Text for collection object identifiers
          co_identifier_castor_text = row['guid']
          co_identifier_morphbank_text = row['morphbank_specimen_id']
          co_identifier_drm_lab_voucher_text = "#{row['voucher_number_prefix']}#{row['voucher_number_string']}"

          # If the drm lab voucher identifier text has already been used, don't attach it
          # by setting it blank
          if drm_lab_voucher_texts.has_key?(co_identifier_drm_lab_voucher_text)
            co_identifier_drm_lab_voucher_text = ''

          # Create a new entry with the lab voucher text as the key
          else
            drm_lab_voucher_texts[co_identifier_drm_lab_voucher_text] = true
          end

          # Collection object identifiers
          co_identifier_castor = {
            type: 'Identifier::Global::Uri',
            identifier: co_identifier_castor_text
          }

          co_identifier_morphbank = {
            type: 'Identifier::Global::MorphbankSpecimenNumber',
            identifier: co_identifier_morphbank_text
          }

          co_identifier_drm_lab_voucher = {
            namespace: namespace_drm_lab_voucher,
            type: 'Identifier::Local::CatalogNumber',
            identifier: co_identifier_drm_lab_voucher_text
          }

          co_identifier_drm_dna = {
            namespace: namespace_drm_dna_voucher,
            type: 'Identifier::Local::CatalogNumber',
            identifier: sample_code_identifier_text
          }

          # Add collection object identifiers
          co_identifiers = []
          co_identifiers.push(co_identifier_castor)             if co_identifier_castor_text.present?
          co_identifiers.push(co_identifier_morphbank)          if co_identifier_morphbank_text.present?
          co_identifiers.push(co_identifier_drm_lab_voucher)    if co_identifier_drm_lab_voucher_text.present?
          co_identifiers.push(co_identifier_drm_dna)            if sample_code_identifier_text.present?

          # OriginRelationship between CollecitonObject and Extract
          co_origin_relationships_attributes = [{ new_object: extract }]

          # Data attributes
          co_data_attributes = []

          if row['specimen_number'].present?
            co_data_attributes.push({
              type: 'ImportAttribute',
              import_predicate: 'SpecimenNumber',
              value: row['specimen_number']
            })
          end

          # Create collection object
          co = CollectionObject.new({
            type: 'Specimen',
            total: 1,
            identifiers_attributes: co_identifiers,
            origin_relationships_attributes: co_origin_relationships_attributes,
            data_attributes_attributes: co_data_attributes
          })

          # Collecting event that this collection object corresponds to
          ce = CollectingEvent.with_identifier(row['collecting_event_guid']).take
          co.collecting_event = ce if ce.present?

          parse_result.objects[:collection_object].push(co);
          @total_data_lines += 1 if co.present?

          # Taxon determination between this object and otus this object belongs to
          otus = Otu.with_identifier(row['taxon_guid'])

          otus.each do |otu|
            taxon_determination = TaxonDetermination.new(otu: otu, biological_collection_object: co)
            parse_result.objects[:taxon_determination].push(taxon_determination)
          end

        #rescue
        end
      end

      @total_lines = i
    end
    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end
