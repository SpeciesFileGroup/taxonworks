# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::CollectingEvents::CastorInterpreter < BatchLoad::Import

    def initialize(**args)
      @collecting_events = {}
      super(args)
    end

    # TODO: update this
    def build_collecting_events
      # Castor          CTR
      # DRMFieldNumbers DRMFN
      namespace_castor = Namespace.find_by(name: 'Castor')
      namespace_drm_field_numbers = Namespace.find_by(name: 'DRMFieldNumbers')

      i = 1
      # loop throw rows
      csv.each do |row|
        # Only accept records from DRM to keep things simple for now
        next if row['locality_code_prefix'] != "DRM"

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collecting_event] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW 
          #  ...

          # Text for identifiers
          ce_identifier_castor_text = row['guid']
          ce_identifier_drm_field_numbers_text = "#{row['locality_code_prefix']}#{row['locality_code_string']}"#{row['locality_database']}"
      
          # Identifiers
          ce_identifier_castor = { namespace: namespace_castor,
                                    type: 'Identifier::Local::CollectingEvent',
                                    identifier: ce_identifier_castor_text }
                                          
          ce_identifier_drm_field_numbers = { namespace: namespace_drm_field_numbers,
                                              type: 'Identifier::Local::CollectingEvent',
                                              identifier: ce_identifier_drm_field_numbers_text }

          # Collecting event
          ce_identifiers = []
          ce_identifiers.push(ce_identifier_castor)             if !ce_identifier_castor.blank?
          ce_identifiers.push(ce_identifier_drm_field_numbers)  if !ce_identifier_drm_field_numbers.blank?

          ce_attributes = { verbatim_locality:                row['verbatim_location'],
                            verbatim_geolocation_uncertainty: (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip,
                            verbatim_date:                    row['verbatim_date'],
                            start_date_day:                   row['start_date_day'],
                            start_date_month:                 row['start_date_month'],
                            start_date_year:                  row['start_date_year'],
                            end_date_day:                     row['end_date_day'],
                            end_date_month:                   row['end_date_month'],
                            end_date_year:                    row['end_date_year'],
                            verbatim_longitude:               row['longitude'],
                            verbatim_latitude:                row['latitude'],
                            verbatim_method:                  row['method'],
                            field_notes:                      row['field_notes'],
                            verbatim_collectors:              row['verbatim_collectors'],
                            verbatim_habitat:                 row['verbatim_habitat'],
                            minimum_elevation:                row['minimum_elevation'],
                            maximum_elevation:                row['maximum_elevation'],
                            identifiers_attributes:           ce_identifiers}
          

          ce = CollectingEvent.new(ce_attributes)

          parse_result.objects[:collecting_event].push(ce)
        #rescue
           # ....
        end
        i += 1
      end
    end

    def build
      if valid?
        build_collecting_events
        @processed = true
      end
    end

  end
end
