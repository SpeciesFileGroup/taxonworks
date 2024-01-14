module BatchLoad
  class Import::CollectingEvents::CastorInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      @collecting_events = {}
      super(**args)
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_collecting_events
      # DRMFieldNumbers DRMFN
      namespace_drm_field_numbers = Namespace.find_by(name: 'DRMFieldNumbers')

      @total_data_lines = 0
      i = 0

      # locality code DRM/JSS should be fully parsed
      # all have guid identifier, all but NONE have field numbers identifiers
      # for all locality codes put collecting_info into verbatim fields
      csv.each do |row|
        i += 1
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collecting_event] = []

        @processed_rows[i] = parse_result

        next if row['locality_code_prefix'] == 'NABemb'

        begin # processing
          # Text for identifiers
          ce_identifier_castor_text = row['guid']
          ce_identifier_drm_field_numbers_text = "#{row['locality_code_prefix']}#{row['locality_code_string']}" if row['locality_code_prefix'] != 'NONE'

          # Identifiers
          ce_identifier_castor = {
            type: 'Identifier::Global::Uri',
            identifier: ce_identifier_castor_text
          }

          ce_identifier_drm_field_numbers = {
            namespace: namespace_drm_field_numbers,
            type: 'Identifier::Local::TripCode',
            identifier: ce_identifier_drm_field_numbers_text
          }

          # Collecting event
          ce_identifiers = []
          ce_identifiers.push(ce_identifier_castor)             if ce_identifier_castor_text.present?
          ce_identifiers.push(ce_identifier_drm_field_numbers)  if ce_identifier_drm_field_numbers_text.present?

          ce_attributes = {
            verbatim_locality:                row['verbatim_location'],
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
            identifiers_attributes:           ce_identifiers
          }

          ce = CollectingEvent.new(ce_attributes)

          # Assign geographic area to collecting event
          county = row['county']
          state_province = row['state_province']
          country = row['country']

          country = 'United States' if country == 'USA'

          geographic_area_params = []

          if county.present?
            county = county.split.map(&:capitalize).join(' ')
            geographic_area_params.push(county)
          end

          if state_province.present?
            state_province = state_province.split.map(&:capitalize).join(' ')
            geographic_area_params.push(state_province)
          end

          if country.present?
            country = country.split.map(&:capitalize).join(' ')
            geographic_area_params.push(country)
          end

          if geographic_area_params.length > 0
            geographic_areas = GeographicArea.find_by_self_and_parents(geographic_area_params)

            if geographic_areas.any?
              geographic_area = geographic_areas.first
              ce.geographic_area = geographic_area
            end
          end

          parse_result.objects[:collecting_event].push(ce)
          @total_data_lines += 1 if ce.present?
        #rescue
           # ....
        end
      end

      @total_lines = i
    end
    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_collecting_events
        @processed = true
      end
    end
  end
end
