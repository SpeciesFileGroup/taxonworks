module Queries
  # name = Arel::Attribute.new(Arel::Table.new(:countries), :name)
  # func = Arel::Nodes::NamedFunction.new 'zomg', [name]
  # Country.select([name, func]).to_sql

  # FILTERS = {
  #   d_dm:    '(\d+\s\d+\.\d+\'\'*)\s.*(\d+\s\d+\.\d+\'\'*)',
  #   dd:      '\d*\.\d*',
  #   degrees: '[o*\u00b0\u00ba\u02DA\u030a\u221e\u222b\uc2ba]',
  #   minutes: '[\'\'\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032\uc2ba]',
  #   seconds: '[\'\'\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\uc2ba"]'
  # }.freeze

  # TODO: This needs cleaning up (@tuckerjd, @mjy)
  class CollectingEventLatLongExtractorQuery # < Queries::Query
    include Arel::Nodes

    attr_accessor :collecting_event_id
    attr_accessor :filters
    attr_accessor :project_id

    # @param [Integer] collecting_event_id
    # @param [Integer] project_id
    # @param [Array] of symbolized filter names
    # @param [Object] filters
    def initialize(collecting_event_id: nil, project_id: nil, filters: [])

      collecting_event_id = 0 if collecting_event_id.nil?

      @collecting_event_id = collecting_event_id
      @filters             = filters
      @project_id         = project_id
    end

    # TODO: use passed filter symbols to build filter_keys
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
      # remove the names from the named groups
      Arel.sql("(#{all_filters.gsub('?<lat>', '').gsub('?<long>', '')})")
      # start with the first scope
      # scopes      = function(filter_keys.shift)
      # filter_keys.each do |filter|
      # or in each of the other scopes
      # scopes = scopes.or(function(filter))
      # end
      # scopes
    end

    def where_sql
      # with_project_id.and
      # TODO: make sure you select the one of the following which suits your purpose: with or without Verbatim_lat/long preset
      # (verbatim_label_not_empty).and(verbatim_lat_long_empty).and(starting_after).and(filter_scopes).to_sql
      (verbatim_label_not_empty).and(starting_after).and(filter_scopes).to_sql
    end

    def table
      CollectingEvent.arel_table
    end

    # @return [Scope]
    def all
      CollectingEvent.where(where_sql)
    end

    # @param [String] filter regex pattern for matching lat_lomg
    # @return [Scope]
    # def regex(filter)
    #   verbatim_label_not_empty
    # trial(filter)
    # end

    def verbatim_label_not_empty
      # Arel.sql('length(verbatim_label)').gt(0)
      vl = Arel::Attribute.new(Arel::Table.new(:collecting_events), :verbatim_label)
      Arel::Nodes::NamedFunction.new('length', [vl]).gt(0)
    end

    def verbatim_lat_long_empty
      Arel.sql('(verbatim_latitude is null or verbatim_longitude is null)')
    end

    def starting_after
      start_id = Arel::Attribute.new(Arel::Table.new(:collecting_events), :id)
      start_id.gt(collecting_event_id)
    end

    # d =  Arel::Attribute.new(Arel::Table.new(:sources), :cached_nomenclature_date)
    # r  = Arel::Attribute.new(Arel::Table.new(related_table_name), :id)
    # f1 = Arel::Nodes::NamedFunction.new('Now', [] )
    #
    # func = Arel::Nodes::NamedFunction.new('COALESCE', [d, f1])
    # where(Arel::Nodes::NamedFunction.new('date_part', ['year', arel_table[:due_date]]).eq(year).to_sql)
    # def functionX(filter)
    #   vl  = Arel::Attribute.new(table, :verbatim_label)
    #   fun = Arel::Nodes::NamedFunction.new('regexp_matches', [vl, FILTERS[filter]])
    #   fun
    # end

    # @param [String] key to FILTERS regex string
    # @return [Scope]
    def regex_function(filter)
      # verbatim_label_not_empty
      # Arel.sql("verbatim_label ~ '" + FILTERS[filter] + "'")
      # ~* is cased-insensitive match
      regex = Utilities::Geo::REGEXP_COORD[filter].to_s.gsub('(?i-mx:', '').chomp(')')
      "verbatim_label ~* '" + regex + "'"
    end

    # table.project(table[:id], table[:verbatim_label]).where(Arel.sql('length(verbatim_data)').gt(0).and(Arel.sql('verbatim_label ~ \'(\d+\s\d+\.\d+''*)\s.*(\d+\s\d+\.\d+''*)\''))).to_sql
    # def trial(filter)
    #   table.project(Arel.star).where(verbatim_label_not_empty().and(function(filter)))
    # table.project(Arel.star).where(function(filter).and(verbatim_label_not_empty))
    # .project(table[:id], table[:verbatim_label])
    # .where(Arel.sql("verbatim_label ~ " + filter))
    # end
  end
end
