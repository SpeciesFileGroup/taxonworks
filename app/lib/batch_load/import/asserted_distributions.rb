module BatchLoad

  class Import::AssertedDistributions < BatchLoad::Import

    attr_accessor :asserted_distributions

    attr_accessor :data_origin

    # @param [Hash] args
    def initialize(data_origin: nil, **args)
      @asserted_distributions = {}
      @data_origin            = data_origin
      super(**args)
    end

    # when this routine is invoked, the following class variables must be instantiated:
    #   @project_id
    #   @user
    #   @data_origin: one of:
    #                       ["gadm", "SFG", "ne_states", "country_names_and_code_elements",
    #                         "ne_countries", "tdwg_l3", "tdwg_l2", "tdwg_l1", "tdwg_l4"]
    # @return [Integer]
    def build_asserted_distributions
      i = 1
      csv.each do |row|
        i += 1

        row.push('project_id' => @project_id)

        # TODO: FIX! THIS!
        # WAS: next if row.empty? || row.all? { |h, v| v.nil? || v.length == "" }
        next if row.empty?

        row.push('project_id' => @project_id)

        rp = BatchLoad::RowParse.new
        @processed_rows[i] = rp

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.geographic_area(row, @data_origin)

        if o.resolvable? && s.resolvable? && g.resolvable?
          rp.objects[:asserted_distributions] = [AssertedDistribution.new(otu: o.item, source: s.item, geographic_area: g.item, project_id: @project_id, by: @user)]
        else
          rp.parse_errors += o.error_messages unless o.resolvable?
          rp.parse_errors += g.error_messages unless g.resolvable?
          rp.parse_errors += s.error_messages unless s.resolvable?
        end
      end
      @total_lines = i - 1
    end

    # @return [Boolean]
    def build
      if valid?
        build_asserted_distributions
        @processed = true
      end
    end

  end
end

