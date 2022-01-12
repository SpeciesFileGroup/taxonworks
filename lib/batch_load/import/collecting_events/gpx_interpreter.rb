module BatchLoad
  class Import::CollectingEvents::GPXInterpreter < BatchLoad::Import

    # SAVE_ORDER = [:georeference, :collecting_event]

    def initialize(**args)
      @collecting_events = {}
      @ce_namespace = args.delete(:ce_namespace)
      super(**args)
    end


    # methode override for GPX processing which is quite different from CSV
    # @return [Hash, nil]
    def csv
      @csv = GPXToCSV.gpx_to_csv(GPX::GPXFile.new(gpx_file: @file.tempfile.path))
    end

    # TODO: update this
    def build_collecting_events
      @total_data_lines = 0
      i = 0

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collecting_event] = []

        @processed_rows[i] = parse_result

        begin
          start_date = row['start_date']
          end_date = row['end_date']
          min_elev = row['minimum_elevation']
          max_elev = row['maximum_elevation']

          # blocked by helper methods: Issue #800
          verbatim_date = nil
          verbatim_date = "#{start_date}" if start_date.present?
          verbatim_date += " to #{end_date}" if end_date.present?

          ce_attributes = {verbatim_label: row['name'],
                           verbatim_date: verbatim_date,
                           minimum_elevation: min_elev,
                           maximum_elevation: max_elev}

          geo_json = row['geojson']

          unless geo_json.blank?
            ce_attributes[:gpx_georeferences_attributes] = [{geographic_item_attributes: {shape: geo_json}}]
          end

          ce = CollectingEvent.new(ce_attributes)
          parse_result.objects[:collecting_event] << ce
          @total_lines = i
        rescue
          # ....
        end

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
