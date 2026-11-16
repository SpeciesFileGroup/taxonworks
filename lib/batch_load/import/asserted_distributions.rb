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

        if line = line_citing[citation_key]
          rp.parse_errors << "Duplicates the OTU, area and source of line #{line}."
        elsif already_cited_in_database?(asserted_distribution, s.item)
          rp.parse_errors << 'Source is already cited on the existing ' \
            'asserted distribution for this OTU and area.'
        elsif asserted_distribution
          # A new source for an asserted distribution already in the database
          # or built by an earlier line.
          line_citing[citation_key] = i

          rp.objects[:citations] = [
            detached_citation(asserted_distribution, s.item)
          ]
        else
          # `source:` builds the asserted distribution's origin citation, so
          # this line's citation is the original one (is_original: true).
          # Citations added by detached_citation are not.
          asserted_distribution = AssertedDistribution.new(
            asserted_distribution_object: o.item,
            source: s.item,
            asserted_distribution_shape: g.item,
            project_id: @project_id,
            by: @user
          )
          rp.objects[:asserted_distributions] = [asserted_distribution]
          line_citing[citation_key] = i
          @asserted_distributions[pair_key] = asserted_distribution
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
    def line_citing
      @line_citing ||= {}
    end

    # Any citation of the source counts, with or without pages.
    # Checked here, rather than left to Citation validation, because it's
    # stricter (see below), and to report a clear parse error.
    # @return [Boolean]
    def already_cited_in_database?(asserted_distribution, source)
      return false unless asserted_distribution&.persisted?

      # Stricter than Citation's uniqueness validation (scoped to pages), since
      # a page-less citation next to a paged one of the same source is
      # probably not useful.
      asserted_distribution.citations.where(source:).exists?
    end

    # The citation for the file line being built, on an existing asserted
    # distribution (in the database, or built by an earlier line, and so
    # saved first). The asserted distribution isn't told about the citation,
    # so the citation can't affect that asserted distribution's validity or
    # save; it's validated, saved, and reported on its own line. (The
    # citation still validates the asserted distribution it cites.)
    # @return [Citation]
    def detached_citation(asserted_distribution, source)
      # Not original (is_original: nil); only the citation the asserted
      # distribution was created with is.
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

