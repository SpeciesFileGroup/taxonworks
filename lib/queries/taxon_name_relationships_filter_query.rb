module Queries

  class TaxonNameRelationshipsFilterQuery < ::Query::Filter

    PARAMS = [
      :taxon_name_id, 
      :keyword_args,
      :person_id
    ].freeze

    attr_accessor :taxon_name_id

    attr_accessor :keyword_args

    # @return [Array]
    attr_accessor :taxon_name_relationship_id

    # @param [Hash] args
    def initialize(query_params)
      super
      return if params[:taxon_name_id].blank?
      @taxon_name_relationship_id = params[:taxon_name_relationship_id]
      @taxon_name_id = params[:taxon_name_id]
      @project_id = params[:project_id]
      @keyword_args = params[:keyword_args]
    end

    # @return [Array]
    def of_type
      keyword_args[:of_type]
    end

    # @return [Boolean]
    def as_subject?
      keyword_args[:as_subject] == 'true'
    end

    # @return [Boolean]
    def as_object?
      keyword_args[:as_object] == 'true'
    end

    # @return [ActiveRecord::Relation]
    def or_clauses
      clauses = [
        as_subject,
        as_object,
      ].compact

      clauses.push as_subject.or(as_object) if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    # @return [Array]
    def of_types
      keyword_args[:of_types] || []
    end

    # @return [Array]
    def relationship_types
      t = []
      of_types.each do |i|
        t = t + ::STATUS_TAXON_NAME_RELATIONSHIP_NAMES if i == 'status'
        t = t + ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM if i == 'synonym'
        t = t + ::TAXON_NAME_RELATIONSHIP_NAMES_CLASSIFICATION if i == 'classification'
        # t = t + TAXON_NAME_RELATIONSHIPS_JSON[:typification][:all].keys if i == 'type'
      end
      t
    end

    # @return [ActiveRecord::Relation, nil]
    def and_clauses
      if relationship_types.any?
        table[:type].eq_any(relationship_types)
      else
        nil
      end
    end

    # @return [String]
    def where_sql
      clause = or_clauses
      clause = clause.and(and_clauses) if and_clauses
      clause.to_sql
    end

    # @return [ActiveRecord::Relation, nil]
    def as_subject
      if as_subject?
        table[:subject_taxon_name_id].eq(taxon_name_id)
      else
        nil
      end
    end

    # @return [ActiveRecord::Relation, nil]
    def as_object
      if as_object?
        table[:object_taxon_name_id].eq(taxon_name_id)
      else
        nil
      end
    end

  end
end
