# See
#  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
#  https://github.com/rails/arel
#  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
#  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
#  And this:
#    http://blog.arkency.com/2013/12/rails4-preloading/
#    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
#  
module Queries 
  class Query
    include Arel::Nodes
   
    attr_accessor :query_string
    attr_accessor :terms
    attr_accessor :project_id

    # limit based on size and potentially properties of terms
    attr_accessor :dynamic_limit

    def initialize(string, project_id: nil)
      @query_string = string
      @project_id = project_id
      build_terms
    end

    def terms=(string)
      @query_string = string
      build_terms
      terms 
    end

    def terms
      @terms ||= build_terms
    end

    def integers
      query_string.split(/\s+/).select{|t| Utilities::Strings.is_i?(t)}
    end

    def build_terms
      @terms = query_string.split(/\s+/).compact.collect{|t| [t, "#{t}%", "%#{t}%"]}.flatten # , "#{t}%", "%#{t}%"
    end

    def dynamic_limit
      limit = 10 
      case query_string.length
      when 0..3
        limit = 20 
      else
        limit = 100 
      end
      limit
    end

   # generic multi-use bits

   def parent_child_join
      table.join(parent).on(table[:parent_id].eq(parent[:id])).join_sources # !! join_sources ftw
    end

    # Match at two levels, for example, 'wa te" will match "Washington Co., Texas"
    def parent_child_where
      a,b = query_string.split(/\s+/, 2)
      return table[:id].eq(-1) if a.nil? || b.nil?
      table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    end

    def with_id
      if integers.any?
        table[:id].eq_any(integers)
      else
        table[:id].eq(-1)
      end
    end

    def named
      table[:name].matches_any(terms)
    end

    def parent 
      table.alias 
    end

    def with_project_id
      table[:project_id].eq(project_id)
    end

  end
end
