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
#   order_by - 'match_identifiers' puts `match_identifiers` first (sent by
#     the match identifiers facet, independent of the table's `sort`)
#   page, per - Kaminari's; `per` defaults to `default_per`, else Kaminari's
#     default_per_page
#
# Options:
#   default_order - `.order` arguments used only when no sort keys apply
#     (e.g. a controller's usual order); `id` still follows
#   default_per - see `per`
#
# See "Sorting and paging" in lib/queries/ARCHITECTURE.md.
module Queries
  class Pager

    MAX_SORT_KEYS = Queries::Sort::Base::MAX_SORT_KEYS

    attr_reader :set, :params, :default_order, :default_per

    # @param set [ActiveRecord::Relation]
    # @param params [Hash, ActionController::Parameters, nil] or given
    #   inline, e.g. `Queries::Pager.new(set, sort: 'name')`
    # @param default_order [Array, nil] see Options above
    # @param default_per [Integer, nil] see Options above
    def initialize(set, params = nil, default_order: nil, default_per: nil, **inline_params)
      params ||= inline_params
      @set = set
      @params = (params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h).with_indifferent_access
      @default_order = default_order
      @default_per = default_per
    end

    # @return [ActiveRecord::Relation] the ordered page
    def all
      ordered.page(params[:page]).per(params[:per].presence || default_per)
    end

    # @return [ActiveRecord::Relation] the whole set, ordered
    def ordered
      q = plain_set

      entries = sort_entries
      q = q.order(*Array.wrap(default_order)) if entries.empty? && default_order.present?

      entries.each do |key, dir|
        if key == Queries::Sort::MatchIdentifiers::KEY
          q = Queries::Sort::MatchIdentifiers.new(klass, params).apply(q)
        else
          q = sort_class.columns[key].call(q, dir)
        end
      end

      # Always last: a tiebreak for equal sort values, or the whole order when
      # there are no sort keys. Without it, paging can skip or repeat rows.
      q.order(id: :asc)
    end

    # @return [Array<Array(String, Symbol)>] [key, :asc|:desc] pairs that
    #   will be applied, in order
    def sort_entries
      requested = parse_sort(params[:sort]).first(MAX_SORT_KEYS)
      requested.unshift([recent_target, :desc]) if recent?
      requested.unshift([Queries::Sort::MatchIdentifiers::KEY, :asc]) if params[:order_by].to_s == Queries::Sort::MatchIdentifiers::KEY

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
