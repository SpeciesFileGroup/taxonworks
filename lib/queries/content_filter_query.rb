module Queries

  class ContentFilterQuery
    include Arel::Nodes

    attr_accessor :topic_id
    attr_accessor :otu_id
    attr_accessor :hours_ago
    attr_accessor :query_string
    attr_accessor :most_recent_updates

    # @param [Hash] args
    # @return [Ignored]
    def initialize(topic_id: nil, otu_id: nil, hours_ago: nil, query_string: nil, most_recent_updates: nil)
      raise ArgumentError.new('missing a filter') if topic_id.nil? && otu_id.nil? && hours_ago.nil? && most_recent_updates.nil? # TODO: support query_string

      @topic_id = topic_id
      @otu_id = otu_id
      @hours_ago = hours_ago.to_i if hours_ago
      @query_string = query_string
      @most_recent_updates = most_recent_updates.to_i
    end

    # @return [String, nil]
    def where_sql

      clauses = [
        for_topic,
        for_otu,
        recent,
      ].compact

      return nil if clauses.empty?

      scope = clauses.shift
      clauses.each do |c|
        scope = scope.and(c)
      end
      scope.to_sql
    end

    # @return [Scope]
    def all
      q = Content.includes(:otu, :topic)
      s = where_sql
      q = q.where(s).references(:topics, :otus) if s
      q = q.order(updated_at: :desc).limit(most_recent_updates) unless most_recent_updates.zero?
      q
    end

    # @return [Arel::Table]
    def table
      Content.arel_table
    end

    # @return [Arel::Nodes::Equatity]
    def for_topic
      table[:topic_id].eq(topic_id) if topic_id
    end

    # @return [Arel::Nodes::Equatity]
    def for_otu
      table[:otu_id].eq(otu_id) if otu_id
    end

    # @return [Arel::Nodes::Equatity]
    def recent
      table[:updated_at].gt(hours_ago.hours.ago) if hours_ago
    end

   #def recently_updated
   #  if most_recent_updates.nonzero?
   #    table['id'].eq_any(
   #                       Content.order(table['updated_at']).take(most_recent_updates)
   #                      )
   #  end
   #end

  end

end
