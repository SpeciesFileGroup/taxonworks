module Queries

  # TODO: Unify all and filter
  class Georeference::Filter < Queries::Query

    # Query variables
    attr_accessor :collecting_event_id, :collecting_event_ids

    # @param [Hash] params
    def initialize(params)
      params.reject!{ |_k, v| v.nil? || (v == '') } 

      @collecting_event_id = params[:collecting_event_id]
      @collecting_event_ids = [params[:collecting_event_ids]].flatten
    end

    def table
      ::Georeference.arel_table
    end

    def collecting_event_table 
      ::CollectingEvent.arel_table
    end

    def matching_collecting_event_ids
      a = ids_for_collecting_events
      a.empty? ? nil : table[:collecting_event_id].eq_any(a)
    end

    def matching_collecting_event_id
      a = collecting_event_id
      a.nil? ? nil : table[:collecting_event_id].eq(a)
    end

    # @return [Array]
    #   of otu_id
    def ids_for_collecting_events
      ([collecting_event_id] + collecting_event_ids).compact.uniq
    end

    # @return [ActiveRecord::Relation, nil]
    def and_clauses
      clauses = [
        matching_collecting_event_id,
        matching_collecting_event_ids,
      # Queries::Annotator.annotator_params(options, ::Citation),
      ].compact

      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

    def merge_clauses
      clauses = [
      # matching_verbatim_author
      ].compact

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
        ::Georeference.where(a).distinct
      elsif b
        b.distinct
      else
        ::Georeference.all
      end
    end

  end
end
