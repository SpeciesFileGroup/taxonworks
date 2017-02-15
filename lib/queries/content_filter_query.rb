module Queries
  
  class ContentFilterQuery 
    include Arel::Nodes

    attr_accessor :topic_id
    attr_accessor :otu_id
    attr_accessor :hours_ago
    attr_accessor :query_string

    def initialize(topic_id: nil, otu_id: nil, hours_ago: nil, query_string: nil)
      raise ArgumentError.new('missing a filter') if topic_id.nil? && otu_id.nil? && hours_ago.nil? # TODO: support query_string

      @topic_id = topic_id
      @otu_id = otu_id
      @hours_ago = hours_ago.to_i if hours_ago
      @query_string = query_string
    end

    def where_sql
      clauses = [
        for_topic,
        for_otu,
        recent
      ].compact

      scope = clauses.shift
      clauses.each do |c|
        scope = scope.and(c)
      end
      scope.to_sql
    end

    # @return [Scope]
    def all 
      Content.includes(:otu, :topic).where(where_sql).references(:topics, :otus)
    end

    def table
      Content.arel_table  
    end

    def for_topic
      table[:topic_id].eq(topic_id) if topic_id
    end

    def for_otu
      table[:otu_id].eq(otu_id) if otu_id
    end

    def recent 
      table[:updated_at].gt( hours_ago.hours.ago) if hours_ago
    end

  end

end
