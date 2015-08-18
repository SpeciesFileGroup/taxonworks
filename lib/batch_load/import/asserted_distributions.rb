module BatchLoad

  class Import::AssertedDistributions < BatchLoad::Import

    attr_accessor :asserted_distributions

    attr_accessor :data_origin

    def initialize(data_origin: nil, **args)
      @asserted_distributions = {}
      @data_origin = data_origin 
      super(args)
    end

    def build_asserted_distributions
      i = 1
      csv.each do |row|
        i += 1

        next if row.empty? || row.all? { |h, v| v.nil? || v.length == "" }

        rp = BatchLoad::RowParse.new
        @processed_rows.merge!(i => rp)

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.geographic_area(row)

        if o.resolvable? && s.resolvable? && g.resolvable?
          rp.objects[:asserted_distributions] = [AssertedDistribution.new(otu: o.item, source: s.item, geographic_area: g.item, project_id: @project_id, by: @user)]
        else
          rp.parse_errors += o.error_messages if !o.resolvable?
          rp.parse_errors += g.error_messages if !g.resolvable?
          rp.parse_errors += s.error_messages if !s.resolvable?
        end
      end
      @total_lines = i - 1
    end

    def build
      if valid?
        build_asserted_distributions
        @processed = true
      end
    end

  end
end

