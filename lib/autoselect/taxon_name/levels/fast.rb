# lib/autoselect/taxon_name/levels/fast.rb
module Autoselect
  module TaxonName
    module Levels
      # Fast level: prefix-only match on the `cached` column via direct Arel.
      # Goal: satisfy 80%+ of queries with minimal DB overhead (no GIN, no similarity).
      class Fast < ::Autoselect::Level

        def key
          :fast
        end

        def label
          'Fast'
        end

        def description
          'Prefix match on cached display name (fastest, no fuzzy matching)'
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array] of TaxonName instances
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          return [] if term.blank?

          sanitized = ::ApplicationRecord.sanitize_sql_like(term)
          t = ::TaxonName.arel_table

          exact  = t[:cached].eq(term)
          prefix = t[:cached].matches("#{sanitized}%")
          clause = exact.or(prefix)

          scope = ::TaxonName.where(clause.to_sql)
          scope = scope.where(project_id:) if project_id.present?
          scope.order(:cached).limit(20).to_a
        end

      end
    end
  end
end
