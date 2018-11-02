module BatchLoad
  class Import::CollectionObjects::BufferedInterpreter < BatchLoad::Import

    attr_accessor :otu_id, :source_id, :source, :otu

    # @param [Hash] args
    def initialize(**args)
      @source_id = args.delete(:source_id)
      @otu_id = args.delete(:otu_id)
      @source = @source_id.present? ? Source.find(@source_id) : nil
      @otu = @otu_id.present? ? Otu.find(@otu_id) : nil
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
          specimen_args.merge!(taxon_determinations_attributes: [otu_id: otu_id])
        end
        if source_id.present?
          specimen_args.merge!(citations_attributes: [source_id: source_id])
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
