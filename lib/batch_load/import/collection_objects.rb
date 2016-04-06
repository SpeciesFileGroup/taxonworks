module BatchLoad
  # TODO: Originally transliterated from Import::AssertedDistributions: Remove this to-do after successful operation.
  class Import::CollectionObjects < BatchLoad::Import

    attr_accessor :collection_objects

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    def build_collection_objects
      i = 1
      csv.each do |row|
        i += 1

        row.push('project_id' => project_id)

        next if row.empty? || row.all? { |h, v| v.nil? || v.length == "" }

        row.push('project_id' => @project_id)

        rp = BatchLoad::RowParse.new
        @processed_rows.merge!(i => rp)

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.geographic_area(row, @data_origin)

        if o.resolvable? && s.resolvable? && g.resolvable?
          rp.objects[:collection_objects] = [CollectionObjects.new(otu:             o.item,
                                                                   source:          s.item,
                                                                   geographic_area: g.item,
                                                                   project_id:      @project_id,
                                                                   by:              @user)]
        else
          rp.parse_errors += o.error_messages unless o.resolvable?
          rp.parse_errors += g.error_messages unless g.resolvable?
          rp.parse_errors += s.error_messages unless s.resolvable?
        end
      end
      @total_lines = i - 1
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end

