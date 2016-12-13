# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::CollectionObjects::CastorInterpreter < BatchLoad::Import

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # TODO: update this
    def build_collection_objects
      # Castor            CTR
      # Morphbank         MBK
      # DRMLabVoucher     DRMLV
      # DRMFieldVoucher   DRMFV
      # GenBank           DRMDNAV
      namespace_castor = Namespace.find_by(name: 'Castor')
      namespace_morphbank = Namespace.find_by(name: 'Morphbank')
      namespace_drm_lab_voucher = Namespace.find_by(name: 'DRMLabVoucher')
      namespace_drm_field_voucher = Namespace.find_by(name: 'DRMFieldVoucher')
      namespace_drm_dna_voucher = Namespace.find_by(name: 'GenBank')

      i = 1
      # loop throw rows
      csv.each do |row|
        # Only accept records from DRM to keep things simple for now
        next if row['locality_database'] != "DRM"

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collection_object] = []
        parse_result.objects[:extract] = []
        parse_result.objects[:taxon_determination] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW 
          #  ...

          # Text for extract identifiers
          extract_identifier_drm_dna_voucher_text = "#{row['sample_code_prefix']}#{row['sample_code']}"

          # Extract identifiers
          extract_identifier_drm_dna_voucher = { namespace: namespace_drm_dna_voucher,
                                                 type: 'Identifier::Local::CollectionObject',
                                                 identifier: extract_identifier_drm_dna_voucher_text }

          extract_identifiers = []
          extract_identifiers.push(extract_identifier_drm_dna_voucher) if !extract_identifier_drm_dna_voucher_text.blank?

          extract_attributes = { quantity_value: 0, 
                                 quantity_unit: 0, 
                                 verbatim_anatomical_origin: row['taxon_name'], 
                                 year_made: 2015, 
                                 month_made: 10, 
                                 day_made: 10,
                                 identifiers_attributes: extract_identifiers }
          extract = Extract.new(extract_attributes)

          parse_result.objects[:extract].push(extract)

          # Text for collection object identifiers
          co_identifier_castor_guid_text = row['guid']
          # co_identifier_castor_taxon_guid_text = row['taxon_guid']
          co_identifier_morphbank_text = row['morphbank_specimen_id']
          co_identifier_drm_field_voucher_text = row['specimen_number']
          co_identifier_drm_lab_voucher_text = "#{row['voucher_number_prefix']}#{row['voucher_number_stirng']}"

          # Collection object identifiers
          co_identifier_castor_guid = { namespace: namespace_castor,
                                   type: 'Identifier::Local::CollectionObject',
                                   identifier: co_identifier_castor_guid_text }

          # co_identifier_castor_taxon_guid = { namespace: namespace_castor,
          #                          type: 'Identifier::Local::TaxonConcept',
          #                          identifier: co_identifier_castor_taxon_guid_text }

          co_identifier_morphbank = { namespace: namespace_morphbank,
                                      type: 'Identifier::Local::CollectionObject',
                                      identifier: co_identifier_morphbank_text }
                                          
          co_identifier_drm_field_voucher = { namespace: namespace_drm_field_voucher,
                                              type: 'Identifier::Local::CollectionObject',
                                              identifier: co_identifier_drm_field_voucher_text }
                                                  
          co_identifier_drm_lab_voucher = { namespace: namespace_drm_lab_voucher,
                                            type: 'Identifier::Local::CollectionObject',
                                            identifier: co_identifier_drm_lab_voucher_text }                                     

          # OriginRelationship between CollecitonObject and Extract
          co_origin_relationships_attributes = [{ new_object: extract}]

          # Collection object
          co_identifiers = []
          co_identifiers.push(co_identifier_castor_guid)        if !co_identifier_castor_guid_text.blank?
          # co_identifiers.push(co_identifier_castor_taxon_guid)  if !co_identifier_castor_taxon_guid_text.blank?
          co_identifiers.push(co_identifier_morphbank)          if !co_identifier_morphbank_text.blank?
          co_identifiers.push(co_identifier_drm_field_voucher)  if !co_identifier_drm_field_voucher_text.blank?
          co_identifiers.push(co_identifier_drm_lab_voucher)    if !co_identifier_drm_lab_voucher_text.blank?

          co_attributes = { type: 'Specimen', total: 1, identifiers_attributes: co_identifiers, origin_relationships_attributes: co_origin_relationships_attributes }
          co = CollectionObject.new(co_attributes)

          # Collecting event that this collection object corresponds to
          ces = CollectingEvent.with_namespaced_identifier('Castor', row['collecting_event_guid'])
          ce = nil
          ce = ces.first if ces.any?
          co.collecting_event = ce if !ce.nil?

          parse_result.objects[:collection_object].push(co);

          # Taxon determination between this object and taxon name otus this object belongs to
          taxon_names = TaxonName.with_namespaced_identifier('Castor', row["taxon_guid"])
          taxon_name = nil
          taxon_name = taxon_names.first if taxon_names.any?

          if taxon_name
            otus = taxon_name.otus

            otus.each do |otu|
              taxon_determination = TaxonDetermination.new(otu: otu, biological_collection_object: co)
              parse_result.objects[:taxon_determination].push(taxon_determination) if taxon_name
            end
          end
        #rescue
           # ....
           # puts "SOMETHING WENT WRONG WITH COLLECTION OBJECT castor INTERPRETER BATCH LOAD"
        end
        i += 1
      end
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end

  end
end
