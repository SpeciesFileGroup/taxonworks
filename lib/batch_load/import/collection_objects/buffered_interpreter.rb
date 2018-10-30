module BatchLoad
  class Import::CollectionObjects::BufferedInterpreter < BatchLoad::Import

    attr_accessor :specimen_batchload, :otu_id, :otu, :source_id, :source

    # @param [Hash] args
    def initialize(**args)
      @collection_objects = {}
      @specimen_batchload = args.delete(:specimen_batchload)
      unless @specimen_batchload.blank?
        if @specimen_batchload['source_id'].present?
          @source_id = @specimen_batchload['source_id']['source_id']
          @source = Source.find(@source_id) if @source_id.present?
        else
          @source = nil
        end
        if @specimen_batchload['otu_id'].present?
          @otu_id = @specimen_batchload['otu_id']['otu_id']
          @otu = Otu.find(@otu_id) if @otu_id.present?
        else
          @otu = nil
        end
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
        det = row['determinations']
        o_l = row['other_labels']

        if c_e.blank? && det.blank? && o_l.blank?
          parse_result.parse_errors << 'No strings provided for any buffered data.'
          next
        end

        specimen_args = {buffered_collecting_event: c_e,
                         buffered_determinations: det,
                         buffered_other_labels: o_l}

        if otu_id.present?
          specimen_args.merge!(taxon_determinations_attributes: [specimen_batchload['otu_id']])
        end
        if source_id.present?
          specimen_args.merge!(citations_attributes: [specimen_batchload['source_id']])
        end

        begin # processing
          s = Specimen.new(specimen_args)
          parse_result.objects[:specimen].push(s)
        rescue => _e
          raise(_e)
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
