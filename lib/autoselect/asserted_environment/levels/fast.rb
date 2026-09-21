# lib/autoselect/asserted_environment/levels/fast.rb
module Autoselect
  module AssertedEnvironment
    module Levels
      # Fast level: prefix-only match on `uri_label` via direct Arel, scoped to
      # the project - same "deterministic prefix, no fuzzy matching" contract
      # as Autoselect::Otu::Levels::Fast, served off the ae_uri_label_gin_trgm
      # index (a GIN trigram index also serves prefix scans, not just
      # substring ones). `cached` is always just a copy of `uri_label` (see
      # AssertedEnvironment#set_cached), so query the indexed column directly
      # rather than its copy. Results are ENVO terms already used somewhere in
      # the project - selecting one clones its uri/uri_label onto a new
      # AssertedEnvironment (see Autoselect::AssertedEnvironment::Autoselect
      # #response_values), it does not reference the found row itself.
      class Fast < ::Autoselect::Level

        def key
          :fast
        end

        def label
          'Fast'
        end

        def description
          'ENVO terms already used in this project (prefix match, fastest)'
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @return [Array] of AssertedEnvironment instances, deduplicated by uri
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          return [] if term.blank?

          sanitized = ::ApplicationRecord.sanitize_sql_like(term)
          t = ::AssertedEnvironment.arel_table

          clause = t[:uri_label].matches("#{sanitized}%")

          scope = ::AssertedEnvironment.where(clause.to_sql)
          scope = scope.where(project_id:) if project_id.present?

          scope.order(:uri_label).limit(40).to_a.uniq(&:uri).first(20)
        end

      end
    end
  end
end
