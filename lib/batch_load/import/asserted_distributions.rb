module BatchLoad

  class Import::AssertedDistributions < BatchLoad::Import

    attr_accessor :asserted_distributions

    def initialize(**args)
      @asserted_distributions = {} 
      super(args)
    end

    def build_asserted_distributions
      i = 1
      csv.each do |row|
        i += 1

        next if row.empty? || row.all?{|h, v| v.nil? || v.length == ""} 

        rp = BatchLoad::RowParse.new
        @processed_rows.merge!(i => rp)

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.geographic_area(row)

        if o && s && g
          rp.objects[:asserted_distributions] =  [AssertedDistribution.new(otu: o, source: s, geographic_area: g, project_id: @project_id, by: @user)]
        else
          rp.parse_errors << 'OTU was not determinable' if !o
          rp.parse_errors << 'Geographic area was not determinable' if !g
          rp.parse_errors << 'Source was not determinable' if !s
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

