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

        row.push('user_id' => @user_id)
        row.push('project_id' => @project_id)

        rp = BatchLoad::RowParse.new
        @processed_rows[i] = rp

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.shape(row, @data_origin)

        if o.resolvable? && s.resolvable? && g.resolvable?
          pair_key = [o.item.class.base_class.name, o.item.id, g.item.class.base_class.name, g.item.id]
          citation_key = pair_key + [s.item.id]

          if line = cited_lines[citation_key]
            rp.parse_errors << "Duplicates the OTU, area and source of line #{line}."
          elsif asserted_distribution = existing_asserted_distribution(pair_key, o.item, g.item)
            # Another citation for an asserted distribution already in the
            # database or on an earlier line.
            cited_lines[citation_key] = i

            # Reference persisted records by id so that citations aren't
            # added to (and validated with) the shared in-memory record,
            # where one invalid citation would invalidate the others.
            citation_object =
              if asserted_distribution.persisted?
                { citation_object_id: asserted_distribution.id, citation_object_type: 'AssertedDistribution' }
              else
                { citation_object: asserted_distribution }
              end

            rp.objects[:citations] = [
              Citation.new(
                **citation_object,
                source: s.item,
                project_id: @project_id,
                by: @user
              )
            ]
          else
            cited_lines[citation_key] = i
            asserted_distribution = AssertedDistribution.new(
              asserted_distribution_object: o.item,
              source: s.item,
              asserted_distribution_shape: g.item,
              project_id: @project_id,
              by: @user
            )
            @asserted_distributions[pair_key] = asserted_distribution
            rp.objects[:asserted_distributions] = [asserted_distribution]
          end
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

    private

    # @return [Hash]
    #   [object type, object id, shape type, shape id, source id] => first line using it
    def cited_lines
      @cited_lines ||= {}
    end

    # @return [AssertedDistribution, nil]
    #   the (present) asserted distribution for the object/shape pair, built
    #   on an earlier line or already in the database
    def existing_asserted_distribution(pair_key, object, shape)
      @asserted_distributions[pair_key] ||= AssertedDistribution.where(
        project_id: @project_id,
        asserted_distribution_object: object,
        asserted_distribution_shape: shape,
        is_absent: [false, nil]
      ).first
    end
  end
end

