# Authored with assistance from Claude (Anthropic)
#
# Orders a set, then pages it:
#
#   set = Queries::Otu::Filter.new(params).all
#   Queries::Pager.new(set, params).all
#
# A set is a relation of one row per record with no order or limit, e.g.
# `filter.all`. Callers that need the set itself (batch updates, counts,
# subqueries) use it directly; callers that show or take a slice of it (a
# page, "the first N") use the pager, so the slice is always in a stable
# order.
#
# Params:
#   sort - comma-separated keys (or an Array), `-` prefix for descending,
#     e.g. `-updated_at,repository.name`. Keys are those of the model's
#     Queries::Sort::Base subclass, plus `match_identifiers`. Unknown keys are
#     ignored, and only the first MAX_SORT_KEYS are used.
#   recent - true puts `-updated_at` (`-created_at` when
#     `recent_target=created_at`) before any `sort` keys
#   page, per - Kaminari's; `per` defaults to Kaminari's default_per_page
#
# See "Sorting and paging" in lib/queries/ARCHITECTURE.md.
module Queries
  class Pager

    MAX_SORT_KEYS = Queries::Sort::Base::MAX_SORT_KEYS

    attr_reader :set, :params

    # @param set [ActiveRecord::Relation]
    # @param params [Hash, ActionController::Parameters]
    def initialize(set, params = {})
      @set = set
      @params = (params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h).with_indifferent_access
    end

    # @return [ActiveRecord::Relation] the ordered page
    def all
      ordered.page(params[:page]).per(params[:per])
    end

    # @return [ActiveRecord::Relation] the whole set, ordered
    def ordered
      q = plain_set
      references = q.references_values

      sort_entries.each do |key, dir|
        if key == Queries::Sort::MatchIdentifiers::KEY
          q = Queries::Sort::MatchIdentifiers.new(klass, params).apply(q)
        else
          q = sort_class.columns[key].call(q, dir)
        end
      end

      # Always last: a tiebreak for equal sort values, or the whole order when
      # there are no sort keys. Without it, paging can skip or repeat rows.
      q = q.order(klass.arel_table[:id].asc)

      # Rails reads table names out of string ORDER BY clauses (e.g.
      # `sort_identifiers.val`) into `references_values`, and when a caller
      # later adds `includes` it takes those for included tables and switches
      # to a JOIN-based eager load (a DISTINCT ids query plus a matching
      # COUNT, each joined to every included has_many). Sort joins are
      # self-contained SQL and never refer to included associations, so put
      # back the references the set had. `references_values=` changes the
      # relation it's called on, so work on a copy.
      q = q.spawn
      q.references_values = references
      q
    end

    # @return [Array<Array(String, Symbol)>] [key, :asc|:desc] pairs that
    #   will be applied, in order
    def sort_entries
      requested = parse_sort(params[:sort]).first(MAX_SORT_KEYS)
      requested.unshift([recent_target, :desc]) if recent?

      requested
        .select { |key, _| sortable?(key) }
        .uniq { |key, _| key }
    end

    def sort_class
      @sort_class ||= Queries::Sort::Base.for(klass)
    end

    private

    def klass
      set.klass
    end

    # A set with DISTINCT, GROUP BY, a custom select or a `from(...)` subquery
    # can't be ordered by a joined column directly, so reduce it to "these
    # ids" first. A plain set is used as is.
    def plain_set
      return set.except(:order, :limit, :offset) if plain?(set)

      ids = set.except(:order, :limit, :offset, :includes, :preload, :eager_load)
        .reselect(klass.arel_table[:id])

      klass.unscoped.where(id: ids)
        .includes(set.includes_values)
        .preload(set.preload_values)
        .eager_load(set.eager_load_values)
    end

    def plain?(relation)
      !relation.distinct_value &&
        relation.group_values.empty? &&
        relation.having_clause.empty? &&
        relation.select_values.empty? &&
        relation.from_clause.empty?
    end

    def sortable?(key)
      key == Queries::Sort::MatchIdentifiers::KEY || sort_class.columns.key?(key)
    end

    def recent?
      [true, 'true', '1', 1].include?(params[:recent])
    end

    def recent_target
      params[:recent_target].to_s.downcase == 'created_at' ? 'created_at' : 'updated_at'
    end

    def parse_sort(value)
      Array(value)
        .flat_map { |s| s.to_s.split(',') }
        .map(&:strip)
        .reject(&:blank?)
        .map do |entry|
          case entry[0]
          when '-' then [entry[1..], :desc]
          when '+' then [entry[1..], :asc]
          else [entry, :asc]
          end
        end
    end
  end
end
