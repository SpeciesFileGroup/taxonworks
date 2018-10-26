module BatchLoad
  class Import::CollectionObjects::BufferedInterpreter < BatchLoad::Import

    attr_accessor :source_name, :create_time

    # @param [Hash] args
    def initialize(**args)
      @collection_objects = {}
      @create_time = args.delete(:create_time)
      @source_id = args.delete(:source_id)
      if source_id.present?
        @source_name = Source.find(source_id).name
      else
        @source_name = ''
      end
      super(args)
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_collection_objects
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:specimen] = []
        @processed_rows[i] = parse_result

        c_e = row['collecting_event']
        det = row['determiniations']
        o_l = row['other_labels']

        if c_e.blank? && det.blank? && o_l.blank?
          parse_result.parse_errors << 'No string provided for any buffered data.'
          next
        end

        begin # processing
          s = Specimen.new(
              buffered_collecting_event: c_e,
              buffered_determinations: det,
              buffered_other_labels: o_l,
              created_at: created_time.blank? ? nil : created_time,
              attributes_for_citations: [{source_id: source_id}]
          )

          parse_result.objects[:specimen].push(s)
        rescue => _e
          raose(_e)
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
