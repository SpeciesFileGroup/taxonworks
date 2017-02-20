module Queries
  # name = Arel::Attribute.new(Arel::Table.new(:countries), :name)
  # func = Arel::Nodes::NamedFunction.new 'zomg', [name]
  # Country.select([name, func]).to_sql

  FILTERS = {
    d_dm:    '(\d+\s\d+\.\d+\'*)\s.*(\d+\s\d+\.\d+\'*)',
    degrees: '([o*\u00b0\u00ba\u02DA\u030a\u221e\u222b\uc2ba])',
    minutes: '([\'\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032\uc2ba])',
    seconds: '([\'\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\uc2ba"])'
  }.freeze

  class CollectingEventLatLongExtractorQuery
    include Arel::Nodes

    attr_accessor :collecting_event_id
    attr_accessor :filters

    def initialize(collecting_event_id: nil, filters: [])

      @collecting_event_id = collecting_event_id
      @filters             = filters
    end

    def where_sql
      clauses = [
        :d_dm #,
      # :degrees,
      # :minutes,
      # :seconds
      ].compact

      scope = regex(clauses.shift)
      clauses.each do |clause|
        scope = scope.and(clause)
      end
      scope.to_sql
    end

    # @return [Scope]
    def all
      CollectingEvent.where(where_sql)
    end

    def table
      CollectingEvent.arel_table
    end

    def regex(filter)
      table[:verbatim_label].matches(function(filter))
    end

    # d =  Arel::Attribute.new(Arel::Table.new(:sources), :cached_nomenclature_date)
    # r  = Arel::Attribute.new(Arel::Table.new(related_table_name), :id)
    # f1 = Arel::Nodes::NamedFunction.new('Now', [] )
    #
    # func = Arel::Nodes::NamedFunction.new('COALESCE', [d, f1])
    # where(Arel::Nodes::NamedFunction.new('date_part', ['year', arel_table[:due_date]]).eq(year).to_sql)
    def function(filter)
      vl  = Arel::Attribute.new(table, :verbatim_label)
      fun = Arel::Nodes::NamedFunction.new('regexp_matches', [vl, FILTERS[filter]])
      fun
    end

    # t2.project(t2[:id], t2[:verbatim_label]).where(Arel.sql('length(verbatim_data)').gt(0).and(Arel.sql('verbatim_label ~ \'(\d+\s\d+\.\d+''*)\s.*(\d+\s\d+\.\d+''*)\''))).to_sql
    def trial(filter)
      table.project(t2[:id], t2[:verbatim_label])
        .where(Arel.sql('length(verbatim_data)').gt(0)
                 .and(Arel.sql("verbatim_label ~ " + filter))).to_sql
    end

  end

end
