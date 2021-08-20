module Queries

  class Namespace::Filter < Queries::Query
    
    # @param institution [String]
    #   wildcarded to match institution 
    attr_accessor :institution     
  
    # @param name [Array, String]
    # @return [Array] 
    attr_accessor :name               

    # @param short_name [Array, String]
    # @return [Array] 
    attr_accessor :short_name         
    
    # @param verbatim_short_name [Array, String]
    # @return [Array] 
    attr_accessor :verbatim_short_name

    def initialize(params)
      @institution = params[:institution]
      @name = params[:name]
      @short_name = params[:short_name]
      @verbatim_short_name = params[:verbatim_short_name]
    end

    def name 
      [@name].flatten.compact
    end

    def short_name 
      [@short_name].flatten.compact
    end

    def verbatim_short_name 
      [@verbatim_short_name].flatten.compact
    end

    def table
      ::Namespace.arel_table
    end

    def matching_name
      return nil if name.empty?
      table[:name].eq_any(name)
    end

    def matching_short_name
      return nil if short_name.empty?
      table[:short_name].eq_any(short_name)
    end

    def matching_verbatim_name
      return nil if verbatim_short_name.empty?
      table[:verbatim_short_name].eq_any(verbatim_short_name)
    end

    def matching_institution
      return nil if institution.nil?
      table[:institution].matches('%' + insititution + '%')
    end

    # @return [ActiveRecord::Relation, nil]
    def and_clauses
      clauses = [
        matching_name,
        matching_short_name,
        matching_verbatim_name, 

        matching_institution,
      ].compact

      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

    def merge_clauses
      clauses = [ ].compact

      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.merge(b)
      end
      a
    end

    # @return [ActiveRecord::Relation]
    def all
      a = and_clauses
      b = merge_clauses
      if a && b
        b.where(a).distinct
      elsif a
        ::Namespace.where(a).distinct
      elsif b
        b.distinct
      else
        ::Namespace.all
      end
    end

  end
end
