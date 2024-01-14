module Queries
=begin

# TODO: perhaps a utility class of queries

For example:

start_id.gt(collecting_event_id)
            becomes
start_id.gt(Arel::Nodes::Quoted.new(collecting_event_id))

Arel performing automatic type casting is deprecated, and will be removed in Arel 8.0. If you are seeing this, it is
because you are manually passing a value to an Arel predicate, and the `Arel::Table` object was constructed manually.
The easiest way to remove this warning is to use an `Arel::Table` object returned from calling `arel_table` on an
ApplicationRecord subclass.

If you're certain the value is already of the right type, change `attribute.eq(value)` to `attribute.eq
(Arel::Nodes::Quoted.new(value))` (you will be able to remove that in Arel 8.0, it is only required to silence this
deprecation warning).

You can also silence this warning globally by setting `$arel_silence_type_casting_deprecation` to `true`. (Do NOT do
this if you are a library author)

If you are passing user input to a predicate, you must either give an appropriate type caster object to the
`Arel::Table`, or manually cast the value before passing it to Arel.
DEPRECATION WARNING: Passing a column to `quote` has been deprecated. It is only used for type casting, which should be
handled elsewhere. See https://github.com/rails/arel/commit/6160bfbda1d1781c3b08a33ec4955f170e95be11 for more
information. (called from where_sql at
/Users/tuckerjd/src/taxonworks/lib/queries/collecting_event_lat_long_extractor_query.rb:41)
=end

  class CollectingEventLatLongExtractorQuery # < Queries::Query
    include Arel::Nodes

    attr_accessor :collecting_event_id
    attr_accessor :filters
    attr_accessor :project_id

    # @param [Integer] collecting_event_id
    # @param [Integer] project_id
    # @param [Integer] Project_id
    def initialize(collecting_event_id: nil, project_id: nil, filters: [])

      collecting_event_id = 0 if collecting_event_id.nil?

      @collecting_event_id = collecting_event_id
      @filters = filters
      @project_id = project_id
    end

    # @return [String] of all of the regexs available at this time
    def filter_scopes
      if filters.blank?
        filter_keys = Utilities::Geo::REGEXP_COORD.keys.compact
      else
        filter_keys = filters
      end

      all_filters = filter_keys.collect do |kee|
        # attach 'verbatim_label ~ ' to each regex
        regex_function(kee)
      end.join(' OR ')
      # remove the names from the named groups: these don't work for sql regexs
      q1 = "(#{all_filters.gsub('?<lat>', '').gsub('?<long>', '')})"
      q2 = ActiveRecord::Base.send(:sanitize_sql_array, ['(?)', all_filters.gsub('?<lat>', '').gsub('?<long>', '')])
      Arel.sql(q1)
    end

    # @return [String]
    def where_sql
      # TODO: make sure you select the one of the following lines which suits your purpose: with or without
      # Verbatim_lat/long present (default: Verbatim_lat/long is empty)
      (verbatim_label_not_empty).and(verbatim_lat_long_empty).and(starting_after).and(filter_scopes).to_sql
      # (verbatim_label_not_empty).and(starting_after).and(filter_scopes).to_sql
    end

    # @return [Arel::Table]
    def table
      ::CollectingEvent.arel_table
    end

    # @return [Scope]
    def all
      ::CollectingEvent.where(where_sql)
    end

    # @return [Arel::Nodes::NamedFunction]
    def verbatim_label_not_empty
      vl = Arel::Attribute.new(Arel::Table.new(:collecting_events), :verbatim_label)
      Arel::Nodes::NamedFunction.new('length', [vl]).gt(0)
      # Arel::Nodes::NamedFunction.new('length', [vl]).gt(Arel::Nodes::Quoted.new(0))
    end

    # @return [String]
    def verbatim_lat_long_empty
      Arel.sql('(verbatim_latitude is null or verbatim_longitude is null)')
    end

    # @return [Arel::Attribute]
    def starting_after
      start_id = Arel::Attribute.new(Arel::Table.new(:collecting_events), :id)
      start_id.gt(Arel::Nodes::Quoted.new(collecting_event_id))
    end

    # @param [String] filter key to FILTERS regex string
    # @return [Scope]
    def regex_function(filter)
      regex = Utilities::Geo::REGEXP_COORD[filter][:reg].to_s.gsub('(?i-mx:', '').chomp(')')
      "verbatim_label ~* '" + regex + "'"
    end
  end
end
