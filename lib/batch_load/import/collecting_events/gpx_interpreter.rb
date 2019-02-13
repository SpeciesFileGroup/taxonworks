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
      @csv = GPX::GPXFile.new(gpx_file: @file.tempfile.path)
      # @csv = Hash.from_xml(gpx.to_s)
      # gpx = (Hash.from_xml(GPX::GPXFile.new(gpx_file: '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx').to_s))['gpx']end
    end

    # TODO: update this
    def build_collecting_events
      @total_data_lines = 0
      i = 0

      # # loop throw rows
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

      parse_result = BatchLoad::RowParse.new
      parse_result.objects[:geographic_item] = []
      parse_result.objects[:gpx_georeference] = []
      parse_result.objects[:collecting_event] = []
      gpx = csv

      gpx.tracks.each do |tr|
        ce = CollectingEvent.new(verbatim_label: gpx.name,
                                 created_at: gpx.time)
        points = []
        time = nil

        tr.points.each do |pt|
          time = pt.time if time.blank?
          points << Gis::FACTORY.point(pt.lon, pt.lat, pt.elevation)
        end
        ce.created_at = time if gpx.time.blank?
        gi = GeographicItem.new(line_string: Gis::FACTORY.line_string(points))
        parse_result.objects[:geographic_item] << gi
        ref = Georeference::GPX.new(geographic_item: gi)
        # intent is to add this georeference to the collecting_event, but we are saving this for 'create' time.
        # ce.georeferences << ref
        parse_result.objects[:gpx_georeference] << ref
        parse_result.objects[:collecting_event] << ce
        @total_data_lines += 1
      end

      @total_lines = i
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
