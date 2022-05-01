require 'queries/taxon_name/filter'
module Queries
  module BiologicalAssociation

    class Filter 

      include Queries::Concerns::Citations
      include Queries::Concerns::Tags
      include Queries::Concerns::Users

      PARAMS = %w{
        subject_global_id
        object_global_id
        any_global_id 
        biological_relationship_id
      }

      # biological_association_graph_id[]
      # 
      # subject_biological_property[]
      # object_biological_property[]
      #  
      # Collecting Event filter on subject
      # Collecting Event filter on object 
      # Collecting Event filter on any 
      #
      # TaxonName filter on subject
      # TaxonName filter on object 
      # TaxonName filter on any 
      # 
      # OTU filter on subject
      # OTU filter on object
      # OTU filter on any 
      #
      # collecting_event_filter_target -> subject, object, both
      # taxon_name_filter_target -> subject, object, both
      # otu_filter_target -> subject, object, both
      # collection_object_filter_target -> subject, object, both
      #
      # subject_type = Otu, CollectionObject, nil (both)
      # object_type = Otu, CollectionObject, nil (both)
      # 
      # determines otu.taxon_name_id or 
      #             collection_object.taxon_detemrionation.taxon_name-id
      #
      # Citations
      # Tags
      # User (on associations

      attr_accessor :taxon_name_query

      # @return [Symbol]
      #   one of :any, :subject, :object
      # @params [String, nil] 
      # If nil, then :any is returned
      attr_accessor :taxon_name_query_target

      # @return [Array] 
      #   one or more biological association ids
      # @param biological_association_id [Array, Integer]
      attr_accessor :biological_association_id 

      # @return [Array] 
      #   one or more biological relationship ID
      # @param biological_relationship_id [Array, Integer]
      attr_accessor :biological_relationship_id 

      # @return [Array] 
      #   a biological relationship graph ID
      # @param biological_association_graph_id [Array, Integer]
      attr_accessor :biological_association_graph_id

      # @return [Array] 
      attr_accessor :subject_global_id

      # @return [Array] 
      attr_accessor :object_global_id

      # @return [Array] 
      attr_accessor :any_global_id


      def initialize(params)
        params.reject!{ |_k, v| v.blank? } # dump all entries with empty values

        # TODO: perhaps remove
        taxon_name_params = ::Queries::TaxonName::Filter::PARAMS

        @taxon_name_query = ::Queries::TaxonName::Filter.new(
          params.select{|a,b| taxon_name_params.include?(a.to_s) }
        )

        @taxon_name_query_target = params[:taxon_name_query_target]

        @subject_global_id = params[:subject_global_id]
        @object_global_id = params[:object_global_id]
        @any_global_id = params[:any_global_id]
        @biological_relationship_id = params[:biological_relationship_id]

        set_tags_params(params)
        set_user_dates(params)
        # set_citations_params(params)
      end

      # @return [Arel::Table]
      def table
        ::BiologicalAssociation.arel_table
      end

      def base_query
        ::BiologicalAssociation.select('biological_associations.*')
      end

      def taxon_name_query_target
        @taxon_name_query_target.blank? ? :any : @taxon_name_query_target.to_sym
      end

      def biological_association_id 
        [@biological_association_id].flatten.compact
      end

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact
      end

      def biological_association_graph_id
        [@biological_association_graph_id].flatten.compact
      end

      def subject_global_id
        [@subject_global_id].flatten.compact
      end

      def object_global_id
        [@object_global_id].flatten.compact
      end

      def any_global_id
        [@any_global_id].flatten.compact
      end

      # @return [ActiveRecord object, nil]
      # TODO: DRY
      def object_for(global_id)
        if o = GlobalID::Locator.locate(global_id) 
          o
        else
          nil
        end
      end

      def subject_matches(object)
        table["biological_association_subject_id"].eq(object.id).and(
          table["biological_association_subject_type"].eq(object.class.base_class.name) 
        )
      end

      def object_matches(object)
        table["biological_association_object_id"].eq(object.id).and(
          table["biological_association_object_type"].eq(object.class.base_class.name) 
        )
      end

      def matching_global_id(target = :subject, global_ids = [])
        a = global_ids
        b = "#{target}_matches".to_sym

        q = send(b, object_for(a[0]))
        a[1..a.length].each do |i|
          q = q.or( send(b, object_for(i) ))
        end
        q
      end

      def matching_subject_global_id
        return nil if subject_global_id.empty?
        matching_global_id(:subject, subject_global_id)
      end

      def matching_object_global_id
        return nil if object_global_id.empty?
        matching_global_id(:object, object_global_id)
      end

      def matching_any_global_id
        return nil if any_global_id.empty?
        a = matching_global_id(:subject, any_global_id)
        b = matching_global_id(:object, any_global_id)
        if a && b
          return a.or(b)
        else
          return a ? a : b
        end 
      end

      # @return [Arel::Node, nil]
      def matching_biological_relationship_id
        biological_relationship_id.blank? ? nil : table[:biological_relationship_id].eq_any(biological_relationship_id) 
      end

      # @return [Arel::Node, nil]
      def matching_biological_association_id
        biological_association_id.blank? ? nil : table[:id].eq_any(biological_association_id) 
      end

      def matching_taxon_name_query_facet
      end

      def taxon_name_merge_clauses
        c = []

        # Convert base and clauses to merge clauses
        taxon_name_query.base_merge_clauses.each do |i|
          c.push ::CollectionObject.joins(:taxon_name).merge( i )
        end
        c
      end

      def taxon_name_and_clauses
        c = []

        collection_object_base_query = nil
        otu_base_query = nil

        # Convert base and clauses to merge clauses
        taxon_name_query.base_and_clauses.each do |i|
          if taxon_name_query_target == 'subject'
            case subject_type

            when 'collection_object'
              ::BiologicalAssociation
                .targeted_join(target: 'subject', target_class: ::CollectionObject)
                .merge(::Queries::CollectionObject::Filter.new(taxon_name_query: taxon_name_query) 
            when 'otu'

            else

            end

            c.push ::BiologicalAssociation.joins(:taxon_name).where( i )
          elsif taxon_Name_query_target == 'object'

          else

          end

        end
        c
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Array]
      def base_and_clauses
        clauses = []

        clauses += [
          matching_subject_global_id, 
          matching_object_global_id,
          matching_any_global_id,
          matching_biological_relationship_id,
        ]
        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []
        clauses += taxon_name_merge_clauses + taxon_name_and_clauses

        clauses += [
          # keyword_id_facet,       # See Queries::Concerns::Tags
          # created_updated_facet,  # See Queries::Concerns::Users
          # identifiers_facet,      # See Queries::Concerns::Identifiers
          # identifier_between_facet,
          # identifier_facet, # See Queries::Concerns::Identifiers
          # identifier_namespace_facet,
        ]

        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses
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
        # q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::BiologicalAssociation.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::BiologicalAssociation.all
        end

        # TODO: needs to go, orders mess with chaining.
        # q = q.order(updated_at: :desc) if recent
        q
      end

      # @return [Arel::Table]
      def table
        ::BiologicalAssociation.arel_table
      end
    end
  end
end
