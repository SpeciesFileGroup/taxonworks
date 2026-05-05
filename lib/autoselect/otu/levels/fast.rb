# lib/autoselect/otu/levels/fast.rb
module Autoselect
  module Otu
    module Levels
      # Fast level: prefix-only match via a single LEFT JOIN query; no GIN, no similarity.
      # Covers three patterns in one round-trip:
      #   1. Otu#name (taxon_name_id IS NULL) — exact or prefix
      #   2. TaxonName#cached               — exact or prefix
      #   3. Multi-word hybrid — every possible split of the term into a
      #      (taxon_prefix, otu_part) pair; both halves use prefix matching so
      #      'P PE01' matches 'Pheidole' + 'PE01', 'Ph PE01' also matches, etc.
      #      All split points are OR'd into the same query (one round-trip).
      #
      # Ordering: longer TaxonName#cached first (more specific match floats up),
      # then shorter Otu#name (more specific OTU name floats up).
      class Fast < ::Autoselect::Level

        def key
          :fast
        end

        def label
          'Fast'
        end

        def description
          'Prefix match on OTU name and linked taxon name cached (no fuzzy matching)'
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array<Otu>]
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          return [] if term.blank?

          sanitized = ::ApplicationRecord.sanitize_sql_like(term)
          o  = ::Otu.arel_table
          tn = ::TaxonName.arel_table

          # Pattern 1 — standalone OTU name (no taxon_name attachment)
          p1 = o[:taxon_name_id].eq(nil).and(
            o[:name].eq(term).or(o[:name].matches("#{sanitized}%"))
          )

          # Pattern 2 — OTU backed by a TaxonName whose cached column matches
          p2 = tn[:cached].eq(term).or(tn[:cached].matches("#{sanitized}%"))

          conditions = p1.or(p2)

          # Pattern 3 — multi-word hybrid: try every split point so that both
          # short abbreviations ('P PE01') and longer prefixes ('Phei PE01') work.
          # The taxon half uses a prefix match; the OTU half uses exact-or-prefix.
          words = term.split(' ')
          if words.length >= 2
            hybrid = (1...words.length).map do |i|
              taxon_part = words[0, i].join(' ')
              otu_part   = words[i..].join(' ')
              s_taxon = ::ApplicationRecord.sanitize_sql_like(taxon_part)
              s_otu   = ::ApplicationRecord.sanitize_sql_like(otu_part)
              tn[:cached].matches("#{s_taxon}%").and(
                o[:name].eq(otu_part).or(o[:name].matches("#{s_otu}%"))
              )
            end.reduce(:or)

            conditions = conditions.or(hybrid)
          end

          scope = ::Otu.left_joins(:taxon_name).where(conditions)
          scope = scope.where(project_id:) if project_id.present?
          # Longer cached = more specific taxon; shorter otu name = more specific OTU.
          scope = scope.order(
            Arel.sql('length(coalesce(taxon_names.cached, \'\')) desc nulls last, length(coalesce(otus.name, \'\')) asc nulls last')
          )
          scope.limit(20).to_a
        end

      end
    end
  end
end
