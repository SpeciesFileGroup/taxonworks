module BatchLoad
  class Import::CollectingEvents::GpxInterpreter < BatchLoad::Import

    # SAVE_ORDER = [:georeference, :collecting_event]

    def initialize(**args)
      @collecting_events = {}
      @ce_namespace = args.delete(:ce_namespace)
      super(args)
    end


    # methode override for GPX processing which is quite different from CSV
    # @return [Hash, nil]
    def csv
      gpx_file = GPX::GPXFile.new(gpx_file: @file.tempfile.path)
      # @csv = Hash.from_xml(gpx.to_s)
      # gpx = (Hash.from_xml(GPX::GPXFile.new(gpx_file: '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx').to_s))['gpx']end
      # @csv = CSV.parse(gpx_string, {col_sep: "\t", headers: true, encoding: 'UTF-8'})
      @csv = CSV.parse(Utilities::GPXToCSV.gpx_to_csv(gpx_file),
                       {headers: true,
                        col_sep: "\t",
                        encoding: 'UTF-8'})
    end

    # TODO: update this
    def build_collecting_events
      @total_data_lines = 0
      i = 0

      # # loop through rows
      # csv.each do |row|
      #   i += 1
      #
      #   parse_result = BatchLoad::RowParse.new
      #   parse_result.objects[:collecting_event] = []
      #
      #   @processed_rows[i] = parse_result
      #
      #   begin # processing
      #     # use a BatchLoad::ColumnResolver or other method to match row data to TW
      #     #  ...
      #
      #     @total_data_lines += 1
      #   rescue
      #      # ....
      #   end
      # end

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collecting_event] = []

        @processed_rows[i] = parse_result

        begin
          start_date = row['start_date']
          end_date = row['end_date']
          verbatim_date = nil
          verbatim_date = "#{start_date}" if start_date.present?
          verbatim_date += " to #{end_date}" if end_date.present
          ce_attributes = {verbatim_label: row['name'],
                           verbatim_date: verbatim_date}
          geo_json = row['geojson']
          unless geo_json.blank?
            shape = RGeo::GeoJSON.decode(geo_json, json_parser: :json)
            geographic_item_attributes = {type: 'Georeference::GPX'}
            case shape.type
              when 'point'
              when 'line_string'
            end
            ce_attributes[:geofererences_attributes] = {geographic_item_attributes: geographic_item_attributes}
          end

          ce = CollecctingEvent.new(ce_attributes)
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

    def create
      @create_attempted = true
      if ready_to_create?
        sorted_processed_rows.each_value do |objs|
          gr_attributes = objs[:georeference].attributes
          gr_attributes[:geographic_item_attributes] = objs[:geographic_item].attributes
          ce_attributes = objs[:collecting_event].attributes
          ce_attributes[:gpx_georeference] = gr_attributes
          CollectingEvent.new(ce_attributes)
        end
        save_order
      end
    end
  end
  # gpx = GPX::GPXFile.new(:gpx_file => '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx')
end
