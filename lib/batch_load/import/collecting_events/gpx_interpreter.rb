module BatchLoad
  class Import::CollectingEvents::GpxInterpreter < BatchLoad::Import

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
        # TODO: What kind of Georeference do we make:
        # 1)  GeoLocate: make a fake Tulane request?
        # 2)  VerbatimData: has no provision for line_string (gpx.tracks)
        # 3)  GoogleMap: mimic the use of GoogleMaps to produse a track?
        # 4)  GPX: create a new Georeference sub-class to embody a more complete version of GPX?
        ref = Georeference::GPX.new(geographic_item: gi)
        ce.georeferences << ref
        parse_result.objects[:georeference] = ref
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
  end
  # gpx = GPX::GPXFile.new(:gpx_file => '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx')
end
