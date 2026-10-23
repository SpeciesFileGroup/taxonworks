# Authored with assistance from Claude (Anthropic)
#
# The sort keys of one model. Subclass per model as `Queries::<Model>::Sort`
# in `lib/queries/<model>/sort.rb`, overriding `columns_uncached` with the
# `Queries::Sort::Resolver` helpers (`direct`, `association`, `custom`, ...).
# Each key maps to a lambda `->(query, dir) { ... }` that adds joins and an
# ORDER BY, and never adds or removes rows.
#
# Models without a Sort class get `updated_at`/`created_at` (see `.for`).
#
# See "Sorting and paging" in lib/queries/ARCHITECTURE.md.
module Queries
  module Sort
    class Base
      include Queries::Sort::Resolver
      include Queries::Sort::ObjectOtu

      # Each sort key can add a join, so an unbounded count is an easy way to
      # force an expensive query. Keys past this are ignored.
      MAX_SORT_KEYS = 5

      # Every model has these, see `recent` in Queries::Pager.
      TIMESTAMP_COLUMNS = %w[updated_at created_at].freeze

      # @return [Class] the model whose keys these are, from the class name,
      #   e.g. Queries::Otu::Sort -> ::Otu
      def self.referenced_klass
        @referenced_klass ||= name.deconstantize.demodulize.constantize
      end

      # @return [Hash{String => Proc}] key => ->(query, dir)
      # Memoized per class: building it reflects over associations and
      # columns, which is the same for the lifetime of the class.
      def self.columns
        @columns ||= timestamp_columns.merge(columns_uncached)
      end

      # Subclasses override this, not `columns`.
      def self.columns_uncached
        {}
      end

      # The keys the frontend can sort by, see QueriesController#sortable_columns.
      def self.keys
        columns.keys
      end

      # @param klass [Class] a model, or an STI subclass of one
      # @return [Class] `Queries::<base class>::Sort`, or, for a model
      #   without one, a Sort with only the timestamp keys
      def self.for(klass)
        base = klass.base_class
        sort = "Queries::#{base.name}::Sort".safe_constantize
        return sort if sort && sort < self

        @generic ||= {}
        @generic[base.name] ||= Class.new(self) do
          define_singleton_method(:referenced_klass) { base }
          define_singleton_method(:name) { "Queries::Sort::Base(#{base.name})" }
        end
      end

      def self.timestamp_columns
        return {} if BLACKLISTED_CLASSES.include?(referenced_klass.name)

        (TIMESTAMP_COLUMNS & referenced_klass.column_names).index_with { |c| direct(c) }
      end
      private_class_method :timestamp_columns
    end
  end
end
