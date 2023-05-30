module Queries
  module Observation

    # !! TODO: needs tests
    class Filter < Query::Filter
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::Depictions
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Protocols
      include Queries::Concerns::Notes
      include Queries::Concerns::Citations

      PARAMS = [
        :character_state_id,
        :collection_object_id,
        :descendants,
        :descriptor_id,
        :descriptor_id,
        :observation_id,
        :observation_matrix_id,
        :observation_object_global_id,
        :observation_object_type,
        :observation_type,
        :otu_id,
        :taxon_name_id,

        charater_state_id: [],
        collection_object_id: [],
        descriptor_id: [],
        observation_id: [],
        observation_matrix_id: [],
        observation_object_type: [],
        observation_type: [],
        otu_id: [],
        taxon_name_id: [],
      ].freeze

      # @return Array
      attr_accessor :observation_id

      # @return Array
      attr_accessor :character_state_id

      # @return Array
      attr_accessor :collection_object_id

      # @return Boolean
      attr_accessor :descendants

      # @return Array
      attr_accessor :descriptor_id

      # @return [Array]
      attr_accessor :observation_matrix_id

      # @return String, nil
      attr_accessor :observation_object_global_id

      # @return Array
      attr_accessor :observation_type

      # @return Array
      attr_accessor :otu_id

      # @return Array
      attr_accessor :taxon_name_id

      def initialize(query_params)
        super

        @observation_id = params[:observation_id]
        @otu_id = params[:otu_id]
        @collection_object_id = params[:collection_object_id]
        @observation_object_global_id = params[:observation_object_global_id]
        @descriptor_id = params[:descriptor_id]
        @observation_type = params[:observation_type]
        @character_state_id = params[:character_state_id]
        @observation_matrix_id = params[:observation_matrix_id]
        @observation_object_type = params[:observation_object_type]

        @taxon_name_id = params[:taxon_name_id]
        @descendants = boolean_param(params, :descendants)

        set_data_attributes_params(params)
        set_protocols_params(params)
        set_citations_params(params)
        set_depiction_params(params)
        set_tags_params(params)
        set_notes_params(params)
      end

      def observation_id
        [@observation_id].flatten.compact.uniq
      end

      def observation_object_type
        [@observation_object_type].flatten.compact.uniq
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact.uniq
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact.uniq
      end

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def collection_object_id
        [@collection_object_id].flatten.compact.uniq
      end

      def descriptor_id
        [@descriptor_id].flatten.compact.uniq
      end

      def character_state_id
        [@character_state_id].flatten.compact.uniq
      end

      def observation_type
        [@observation_type].flatten.compact.uniq
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        if descendants
          t = ::TaxonName.descendants_of(taxon_name_id)
        else
          t = ::TaxonName.where(id: taxon_name_id)
        end

        a = ::Observation.joins("JOIN otus ON observations.observation_object_id = otus.id AND observations.observation_object_type = 'Otu'")
          .where(otus: {taxon_name_id: t})

        b = ::Observation.joins("JOIN collection_objects ON observations.observation_object_id = collection_objects.id AND observations.observation_object_type = 'CollectionObject'")
          .joins('JOIN taxon_determinations ON taxon_determinations.biological_collection_object_id = collection_objects.id')
          .joins('JOIN otus ON taxon_determinations.otu_id = otus.id')
          .joins('JOIN taxon_names ON taxon_names.id = otus.id')
          .where(taxon_names: {id:  t})

        e = ::Queries::Extract::Filter.new(taxon_name_id: taxon_name_id, descendants: descendants, project_id: project_id).all

        c = ::Observation.joins("JOIN extracts ON observations.observation_object_id = extracts.id AND observations.observation_object_type = 'Extract'")
          .where(extracts: {id: e})

        ::Observation.from( '(' + [a,b,c].collect{|q| "(#{q.to_sql})" }.join(' UNION ') + ') as observations' )
      end

      def observation_matrix_id_facet
        return nil if observation_matrix_id.empty?
        ::Observation.in_observation_matrix(observation_matrix_id)
      end

      # @return [Arel::Node, nil]
      def observation_object_global_id_facet
        return nil if observation_object_global_id.blank?

        # TODO - make a hash method to parameterize these values
        o = GlobalID::Locator.locate(observation_object_global_id)

        a = o.id
        b = o.class.base_class.name

        table[:observation_object_id].eq(a).and(table[:observation_object_type].eq(b))
      end

      # @return [Arel::Node, nil]
      def matching_character_state_id
        character_state_id.blank? ? nil : table[:character_state_id].eq(character_state_id)
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        table[:observation_object_id].eq(collection_object_id).and(table[:observation_object_type].eq('CollectionObject'))
      end

      # @return [Arel::Node, nil]
      def observation_type_facet
        return nil if observation_type.empty?
        table[:type].eq_any(observation_type)
      end

      # @return [Arel::Node, nil]
      def character_state_id_facet
        return nil if character_state_id.empty?
        table[:character_state_id].eq_any(character_state_id)
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:observation_object_id].eq_any(otu_id).and(table[:observation_object_type].eq('Otu'))
      end

      def observation_object_type_facet
        return nil if observation_object_type.empty?
        table[:observation_object_type].eq_any(observation_object_type)
      end

      def descriptor_id_facet
        return nil if descriptor_id.empty?
        table[:descriptor_id].eq_any(descriptor_id)
      end

      def descriptor_query_facet
        return nil if descriptor_query.nil?

        s = 'WITH query_desc_obs AS (' + descriptor_query.all.to_sql + ') ' +
          ::Observation
          .joins('JOIN query_desc_obs as query_desc_obs1 on observations.descriptor_id = query_desc_obs1.id')
          .to_sql

        ::Observation.from('(' + s + ') as observations')
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?

        s = 'WITH query_co_obs AS (' + collection_object_query.all.to_sql + ') ' +
          ::Observation
          .joins("JOIN query_co_obs as query_co_obs1 on observations.observation_object_id = query_co_obs1.id and observations.observation_object_type = 'CollectionObject'")
          .to_sql

        ::Observation.from('(' + s + ') as observations')
      end

      def otu_query_facet
        return nil if otu_query.nil?

        s = 'WITH query_otu_obs AS (' + otu_query.all.to_sql + ') ' +
          ::Observation
          .joins("JOIN query_otu_obs as query_otu_obs1 on observations.observation_object_id = query_otu_obs1.id and observations.observation_object_type = 'Otu'")
          .to_sql

        ::Observation.from('(' + s + ') as observations')
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_tn_obs AS (' + taxon_name_query.all.to_sql + ') '

        a = ::Observation
          .joins("JOIN collection_objects on observations.observation_object_id = collection_objects.id and observations.observation_object_type = 'CollectionObject'")
          .joins('JOIN taxon_determinations on collection_objects.id = taxon_determinations.biological_collection_object_id')
          .joins('JOIN otus on taxon_determinations.otu_id = otus.id')
          .joins('JOIN query_tn_obs as query_tn_obs1 on otus.taxon_name_id = query_tn_obs1.id')
          .to_sql

        b = ::Observation
          .joins("JOIN otus on observations.observation_object_id = otus.id and observations.observation_object_type = 'Otu'")
          .joins('JOIN query_tn_obs as query_tn_obs2 on otus.taxon_name_id = query_tn_obs2.id')
          .to_sql

        s << ::Observation.from("((#{a}) UNION (#{b})) as observations").to_sql

        ::Observation.from('(' + s + ') as observations')
      end

      def and_clauses
        [
          character_state_id_facet,
          collection_object_id_facet,
          descriptor_id_facet,
          observation_object_global_id_facet,
          observation_object_type_facet,
          observation_type_facet,
          otu_id_facet,
        ]
      end

      def merge_clauses
        [
          collection_object_query_facet,
          descriptor_query_facet,
          observation_matrix_id_facet,
          otu_query_facet,

          taxon_name_query_facet,
          taxon_name_id_facet,
        ]
      end

    end
  end
end
