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
      i = 0
      csv.each do |row|
        i += 1

        row.push('user_id' => @user_id)
        row.push('project_id' => @project_id)

        rp = BatchLoad::RowParse.new
        @processed_rows[i] = rp

        o = BatchLoad::ColumnResolver.otu(row)
        s = BatchLoad::ColumnResolver.source(row)
        g = BatchLoad::ColumnResolver.shape(row, @data_origin)

        if !o.resolvable? || !s.resolvable? || !g.resolvable?
          rp.parse_errors += o.error_messages if !o.resolvable?
          rp.parse_errors += g.error_messages if !g.resolvable?
          rp.parse_errors += s.error_messages if !s.resolvable?
          next
        end

        pair_key = [o.item.class.base_class.name, o.item.id, g.item.class.base_class.name, g.item.id]
        citation_key = pair_key + [s.item.id]
        asserted_distribution = existing_asserted_distribution(pair_key, o.item, g.item)

        if line = cited_lines[citation_key]
          rp.parse_errors << "Duplicates the OTU, area and source of line #{line}."
        elsif already_cited?(asserted_distribution, s.item)
          rp.parse_errors << 'Source is already cited on the existing ' \
            'asserted distribution for this OTU and area.'
        elsif asserted_distribution
          # Another citation for an asserted distribution already in the
          # database or on an earlier line.
          cited_lines[citation_key] = i

          rp.objects[:citations] = [
            detached_citation(asserted_distribution, s.item)
          ]
        else
          asserted_distribution = AssertedDistribution.new(
            asserted_distribution_object: o.item,
            source: s.item,
            asserted_distribution_shape: g.item,
            project_id: @project_id,
            by: @user
          )
          rp.objects[:asserted_distributions] = [asserted_distribution]

          # Later lines for this pair would only inherit this line's error, so
          # let them build (and report on) their own if this one is invalid.
          if asserted_distribution.valid?
            cited_lines[citation_key] = i
            @asserted_distributions[pair_key] = asserted_distribution
          end
        end
      end
      @total_lines = i
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

    # Any citation of the source counts, with or without pages.
    # Checked here, rather than left to Citation validation, so the error
    # message isn't obscured by the (then also invalid) asserted distribution.
    # @return [Boolean]
    def already_cited?(asserted_distribution, source)
      return false unless asserted_distribution&.persisted?

      # Stricter than Citation's uniqueness validation (scoped to pages), since
      # a page-less citation next to a paged one of the same source is
      # probably not useful.
      asserted_distribution.citations.where(source:).exists?
    end

    # A citation on an existing asserted distribution (in the database, or
    # built by an earlier line and saved before this one), saved on its own.
    # The asserted distribution isn't told about the citation, so each line
    # validates, saves, and reports only its own objects.
    # @return [Citation]
    def detached_citation(asserted_distribution, source)
      citation = Citation.new(
        citation_object: asserted_distribution,
        source:,
        project_id: @project_id,
        by: @user
      )
      # Assigning citation_object adds the citation to the asserted
      # distribution's in-memory citations (has_many_inversing); undo that.
      # The citation is unsaved, so this only removes it from memory.
      asserted_distribution.citations.delete(citation)
      citation
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

