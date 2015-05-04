module Queries 

  class Query
    include Arel::Nodes
   
    attr_accessor :query_string

    attr_accessor :terms

    # limit based on size and potentially properties of terms
    attr_accessor :dynamic_limit

    def initialize(string)
      @query_string = string
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

    def build_terms
      @terms = @query_string.split(/\s/).collect{|t| [t, "#{t}%"]}.flatten # , "#{t}%", "%#{t}%"
    end

    def dynamic_limit
      limit = 10 
      case @query_string.length
      when 0..3
        limit = 20 
      else
        limit = 100 
      end
      limit
    end

  end

end
