# lib/autoselect/taxon_name/levels/catalogue_of_life.rb
module Autoselect
  module TaxonName
    module Levels
      class CatalogueOfLife < ::Autoselect::Level
        include ::Autoselect::Levels::ColRecordInfo

        def key
          :catalogue_of_life
        end

        def label
          'Catalogue of Life'
        end

        def description
          'Search the Catalogue of Life for matching names. Returns external results with alignment data for confirmation.'
        end

        def external?
          true
        end

        def record_label(record)
          [record.cached.to_s.presence, col_author_year(record)].compact.join(' ')
        end

        def record_label_html(record, term = nil)
          [record.cached.to_s.presence, col_author_year(record)]
            .compact
            .map { |part| ERB::Util.html_escape(part) }
            .join(' ')
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<OpenStruct>] pseudo-records compatible with TaxonName autoselect format_results
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          raw = ::Vendor::Colrapi.search(term, dataset_id:)
          results = raw['result'] || []
          return [] if results.empty?

          results.map { |col_result| build_pseudo_record(col_result, project_id:, dataset_id:) }
        end

        # Builds one autoselect pseudo-record (alignment + existing-TaxonName check) from
        # a raw CoL nameusage hash. Split out of #call so a caller that already holds the
        # right nameusage hash — Levels::ColValidName, which gets the accepted usage back
        # from Vendor::Colrapi.resolve_accepted_name — can reuse it without a second
        # search() and its per-result classification fetches.
        #
        # @param col_result [Hash] a flat CoL nameusage hash (search-result shape)
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil]
        # @return [OpenStruct] pseudo-record compatible with TaxonName autoselect format_results
        def build_pseudo_record(col_result, project_id: nil, dataset_id: nil)
          # Flat nameusage structure: 'id', 'status', 'name' hash, 'label', 'labelHtml'
          col_name  = col_result.dig('name', 'scientificName') || col_result['label']
          col_rank  = col_result.dig('name', 'rank')&.downcase
          col_name  = ::Vendor::Colrapi.extract_subgenus_name(col_name) if col_rank == 'subgenus'
          extension = ::Vendor::Colrapi.build_extension(col_result, dataset_id:)

          # Flag when the target's rank is not resolvable in TaxonWorks (e.g. 'domain').
          # ColCreator silently skips such rows, so the modal needs to know up-front.
          extension = extension.merge(target_rank_unknown: true) unless rank_resolvable?(col_rank)

          extension = extension.merge(match_against_taxonworks(extension, col_name, col_rank, project_id)) if project_id.present?

          OpenStruct.new(
            id: nil,
            cached: col_name,
            name: col_name,
            rank_string: nil,
            cached_valid_taxon_name_id: nil,
            _col_extension: extension
          )
        end

        private

        # Finds the lowest (most specific) rank in the CoL chain — the target itself first,
        # then ancestors from most- to least-proximal — that unambiguously (exactly one
        # candidate, matched on both name AND rank) exists in this project, then diffs
        # TaxonWorks' REAL ancestor chain from there against CoL's (ColAncestryComparator).
        #
        # This never reparents anything: the target, if it exists at all, is checked first
        # and immediately becomes the anchor, so TaxonWorks' own real ancestor chain — not a
        # separately-found, name-coincidental chain — is always the source of truth for it.
        # Only when the target itself doesn't exist yet does the search continue outward,
        # since attaching a brand-new record to an existing, unambiguous ancestor is a normal
        # creation decision, not a reparenting of anything that already exists.
        #
        # A position with more than one same-name, same-rank candidate is a homonym we have
        # no principled way to pick between (matching by cached name alone never guaranteed a
        # coherent chain) — that stops the walk and blocks Create, same as a real conflict.
        #
        # @return [Hash] merges into the extension: :alignment (kingdom-first, ancestors only
        #   — the target is reported separately below), :chain_consistent,
        #   :target_taxonworks_id, :target_global_id (only when the target itself matched),
        #   :ambiguous_match (only when the walk was stopped by a homonym)
        def match_against_taxonworks(extension, col_name, col_rank, project_id)
          full_chain = extension[:alignment] + [{
            rank: col_rank,
            col_name:,
            col_id: extension[:col_key],
            dataset_id: extension[:col_dataset_id],
            col_authorship: extension[:col_authorship]
          }]

          candidates_by_name = ::TaxonName
            .where(project_id:, cached: full_chain.map { |row| row[:col_name] })
            .group_by(&:cached)

          # When CoL tells us the code, require candidates to match it too — same-name,
          # same-rank homonyms do occur across codes (e.g. a zoological vs a botanical
          # genus sharing a name), and this is the only point that needs the check: once
          # an anchor is chosen, TaxonName's own validate_same_nomenclatural_code already
          # guarantees every real ancestor above it shares its code, so nothing further
          # down this method needs to re-check it.
          expected_nomenclature_code = ::Vendor::Colrapi::COL_CODE_TO_NOMENCLATURE_CODE[extension[:col_code]]

          anchor = nil
          anchor_index = nil

          (full_chain.length - 1).downto(0) do |i|
            row = full_chain[i]
            rank_matched = (candidates_by_name[row[:col_name]] || [])
              .select { |candidate| rank_name_for(candidate.rank_class) == row[:rank] }

            if expected_nomenclature_code
              rank_matched = rank_matched.select { |candidate| candidate.rank_class.nomenclatural_code == expected_nomenclature_code }
            end

            if rank_matched.length > 1
              return ambiguous_result(extension, row, rank_matched.length)
            elsif rank_matched.length == 1
              anchor = rank_matched.first
              anchor_index = i
              break
            end
          end

          if anchor.nil?
            none_alignment = extension[:alignment].map { |row| row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none') }
            return { alignment: none_alignment, chain_consistent: true }
          end

          # self_and_ancestors carries its own baked-in default order, which .order()
          # only appends to (doesn't replace) — unscope it first, same as
          # TaxonName#safe_self_and_ancestors already does, to actually get kingdom-first.
          tw_chain = anchor.self_and_ancestors
            .where.not(rank_class: 'NomenclaturalRank') # excludes the project root
            .unscope(:order)
            .order(generations: :desc)
            .to_a

          diffed = ::Autoselect::TaxonName::ColAncestryComparator.new(
            tw_chain:,
            col_chain: full_chain[0..anchor_index],
            col_code: extension[:col_code]
          ).call

          below_anchor = full_chain[(anchor_index + 1)..].map do |row|
            row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
          end

          merged = diffed + below_anchor
          target_matched = anchor_index == full_chain.length - 1

          {
            alignment: merged[0...-1],
            chain_consistent: merged.none? { |row| row[:match] == 'conflict' },
            **(target_matched ? { target_taxonworks_id: anchor.id, target_global_id: anchor.to_global_id.to_s } : {})
          }
        end

        def rank_name_for(rank_class)
          ::RANKS_LOOKUP[rank_class.to_s]
        end

        def ambiguous_result(extension, row, count)
          none_alignment = extension[:alignment].map { |r| r.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none') }
          {
            alignment: none_alignment,
            chain_consistent: false,
            ambiguous_match: { rank: row[:rank], col_name: row[:col_name], count: }
          }
        end

        # The display author+year for a CoL result.
        #
        # CoL renders a recombination's authorship as the original (basionym) author+year
        # wrapped in parens, followed by the combination authorship, e.g.
        #   "(Chatton, 1925) Whittaker & Margulis, 1978".
        # Per ICZN convention we show only the original author+year, keeping the parens
        # that signal the recombination. A name described in its original genus has no
        # leading parenthetical and is shown verbatim, e.g. "Linnaeus, 1758".
        #
        # @return [String, nil]
        def col_author_year(record)
          ext = record._col_extension
          return nil unless ext

          authorship = ext[:col_authorship].presence
          return nil unless authorship

          if (leading_parenthetical = authorship[/\A\([^)]*\)/])
            leading_parenthetical
          else
            authorship
          end
        end

        def rank_resolvable?(rank_string)
          return false if rank_string.blank?
          r = rank_string.to_s.downcase
          [:ICZN_LOOKUP, :ICN_LOOKUP, :ICNP_LOOKUP, :ICVCN_LOOKUP].any? do |key|
            Object.const_get("::#{key}")[r].present?
          end
        end

      end
    end
  end
end
