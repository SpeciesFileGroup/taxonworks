module Queries
  module Image
    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations

      PARAMS = [
        :biocuration_class_id,
        :collection_object_id,
        :collection_object_scope,
        :depiction_object_type,
        :depictions,
        :image_id,
        :otu_id,
        :sled_image_id,
        :source_id,
        :taxon_name_id,
        :taxon_name_id_target,
        :type_material_depictions,

        biocuration_class_id: [],
        collection_object_id: [],
        depiction_object_type: [],
        image_id: [],
        otu_id: [],
        otu_scope: [],
        sled_image_id: [],
        source_id: [],
        taxon_name_id: [],
      ].freeze

      # @return [Array]
      #   images depicting collecting_object
      attr_accessor :collection_object_id

      # @param collection_object_scope
      #   One or more of:
      #     :all (default, includes all below)
      #
      #     :collection_objects (those on the collection_object)
      #     :observations (those on just the CollectionObject observations)
      #      collecting_events (those on the associated collecting event)
      #     # maybe those on the CE
      attr_accessor :collection_object_scope

      # @return [Boolean, nil]
      #   true - image is used (in a depiction)
      #   false - image is not used
      #   nil - either
      attr_accessor :depictions

      # @return [Array]
      # @param depiction_object_type
      #   one or more names of classes.
      # Restricts Images to those that depict these classes
      attr_accessor :depiction_object_type

      # @return [Array]
      #   images depicting otus
      attr_accessor :otu_id

      # @return [Protonym.id, nil]
      #   return all images depicting an Otu that is self or descendant linked
      #   to this TaxonName
      attr_accessor :taxon_name_id

      # @return [Array]
      # A sub scope of sorts. Purpose is to gather all images
      # possible under an OTU that are of an OTU, CollectionObject or Observation.
      #
      # !! Must be used with an otu_id !!
      # @param otu_scope
      #   One or more of:
      #     :all (default, includes all below)
      #
      #     :otu (those on the OTU)
      #     :otu_observations (those on just the OTU)
      #     :collection_object_observations (those on just those determined as the OTU)
      #     :collection_objects (those on just those on the collection objects)
      #     :type_material (those on CollectionObjects that have TaxonName used in OTU)
      #     :type_material_observations (those on CollectionObjects that have TaxonName used in OTU)
      #
      #     :coordinate_otus  If present adds both.  Use downstream substraction to to diffs of with/out?
      #
      attr_accessor :otu_scope

      # @return [Array]
      attr_accessor :image_id

      # @return [Array]
      #   of biocuration_class ids
      attr_accessor :biocuration_class_id

      # @return [Array]
      attr_accessor :sled_image_id

      # @return [Array]
      attr_accessor :sqed_depiction_id

      # @return [Array]
      #   one or both of 'Otu', 'CollectionObject', defaults to both if nothing provided
      # Only used when `taxon_name_id` provided
      attr_accessor :taxon_name_id_target

      # @return [Array]
      #   depicts some  that is a type specimen
      attr_accessor :type_material_depictions

      # @param params [Hash]
      def initialize(query_params)
        super

        @biocuration_class_id = params[:biocuration_class_id]
        @collection_object_id = params[:collection_object_id]
        @collection_object_scope = params[:collection_object_scope]
        @depiction_object_type = params[:depiction_object_type]
        @depictions = boolean_param(params, :depictions)
        @image_id = params[:image_id]
        @otu_id = params[:otu_id]
        @otu_scope = params[:otu_scope]&.map(&:to_sym)
        @sled_image_id = params[:sled_image_id]
        @sqed_depiction_id = params[:sqed_depiction_id]
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_id_target = params[:taxon_name_id_target]
        @type_material_depictions = boolean_param(params, :type_material_depictions)

        set_citations_params(params)
        set_tags_params(params)
      end

      def image_id
        [ @image_id ].flatten.compact
      end

      def depiction_object_type
        [ @depiction_object_type ].flatten.compact
      end

      def taxon_name_id
        [ @taxon_name_id ].flatten.compact
      end

      def collection_object_id
        [ @collection_object_id ].flatten.compact
      end

      def otu_id
        [ @otu_id ].flatten.compact
      end

      def taxon_name_id_target
        a = [ @taxon_name_id_target ].flatten.compact
        a = ['Otu', 'CollectionObject'] if a.empty?
        a
      end

      def biocuration_class_id
        [ @biocuration_class_id ].flatten.compact
      end

      def otu_scope
        [ @otu_scope ].flatten.compact.map(&:to_sym)
      end

      def collection_object_scope
        [ @collection_object_scope ].flatten.compact.map(&:to_sym)
      end

      def sled_image_id
        [ @sled_image_id ].flatten.compact
      end

      def sqed_depiction_id
        [ @sqed_depiction_id ].flatten.compact
      end

      # @return [Arel::Table]
      def taxon_determination_table
        ::TaxonDetermination.arel_table
      end

      # @return [Arel::Table]
      def otu_table
        ::Otu.arel_table
      end

      # @return [Arel::Table]
      def collection_object_table
        ::CollectionObject.arel_table
      end

      # @return [Arel::Table]
      def type_materials_table
        ::TypeMaterial.arel_table
      end

      # @return [Arel::Table]
      def depiction_table
        ::Depiction.arel_table
      end

      def biocuration_facet
        return nil if biocuration_class_id.empty?
        ::Image.joins(collection_objects: [:depictions]).merge(
          ::CollectionObject::BiologicalCollectionObject.joins(:biocuration_classifications)
          .where(biocuration_classifications: {biocuration_class_id:})
        )
      end

      def depiction_object_type_facet
        return nil if depiction_object_type.empty?
        ::Image.joins(:depictions).where(depictions: {depiction_object_type:})
      end

      def depictions_facet
        return nil if depictions.nil?
        if depictions
          ::Image.joins(:depictions)
        else
          ::Image.where.missing(:depictions)
        end
      end

      def sled_image_facet
        return nil if sled_image_id.empty?
        ::Image.joins(:sled_image).where(sled_images: {id: sled_image_id})
      end

      def sqed_depiction_facet
        return nil if sqed_depiction_id.empty?
        ::Image.joins(depictions: [:sqed_depiction]).where(sqed_depictions: {id: sqed_depiction_id})
      end

      def coordinate_otu_ids
        ids = []
        otu_id.each do |id|
          ids += ::Otu.coordinate_otus(id).pluck(:id)
        end
        ids.uniq
      end

      def otu_id_facet
        # only run this when scope not provided
        return nil if otu_id.empty? || !otu_scope.empty?

        ::Image.joins(:otus).where(otus: {id: otu_id})
      end

      def otu_scope_facet
        return nil if otu_id.empty? || otu_scope.empty?

        otu_ids = otu_id
        otu_ids += coordinate_otu_ids if otu_scope.include?(:coordinate_otus)

        otu_ids.uniq!

        selected = []

        if otu_scope.include?(:all)
          selected = [
            :otu_facet_otus,
            :otu_facet_collection_objects,
            :otu_facet_otu_observations,
            :otu_facet_collection_object_observations,
            :otu_facet_type_material,
            :otu_facet_type_material_observations
          ]
        elsif otu_scope.empty?
          selected = [:otu_facet_otus]
        else
          selected.push :otu_facet_otus if otu_scope.include?(:otus)
          selected.push :otu_facet_collection_objects if otu_scope.include?(:collection_objects)
          selected.push :otu_facet_collection_object_observations if otu_scope.include?(:collection_object_observations)
          selected.push :otu_facet_otu_observations if otu_scope.include?(:otu_observations)
          selected.push :otu_facet_type_material if otu_scope.include?(:type_material)
          selected.push :otu_facet_type_material_observations if otu_scope.include?(:type_material_observations)
        end

        q = selected.collect{|a| '(' + send(a, otu_ids).to_sql + ')'}.join(' UNION ')

        d = ::Image.from('(' + q + ')' + ' as images')
        d
      end

      def collection_object_scope_facet
        return nil if collection_object_id.empty?

        selected = []

        if collection_object_scope.include?(:all)
          selected = [
            :collection_object_facet_collection_objects,
            :collection_object_facet_observations,
            :collection_object_facet_collecting_events,
          ]
        elsif collection_object_scope.present?
          selected.push :collection_object_facet_collection_objects if collection_object_scope.include?(:collection_objects)
          selected.push :collection_object_facet_observations if collection_object_scope.include?(:observations)
          selected.push :collection_object_facet_collecting_events if collection_object_scope.include?(:collecting_events)
        else
          selected.push :collection_object_facet_collection_objects
        end

        q = selected.collect{|a| '(' + send(a).to_sql + ')'}.join(' UNION ')

        d = ::Image.from('(' + q + ')' + ' as images')
        d
      end

      def collection_object_facet_collection_objects
        ::Image.joins(:collection_objects).where(collection_objects: {id: collection_object_id})
      end

      def collection_object_facet_observations
        ::Image.joins(:observations).where(observations: {observation_object_type: 'CollectionObject', observation_object_id: collection_object_id })
      end

      def collection_object_facet_collecting_events
        ::Image.joins(:observations)
          .joins("INNER JOIN collecting_events on collecting_events.id = observations.observation_object_id AND observations.observation_object_type = 'CollectingEvent'")
          .joins('INNER JOIN collection_objects on collection_objects.collecting_event_id = collecting_events.id')
          .where(collection_objects: {id: collection_object_id})
      end

      def otu_facet_type_material_observations(otu_ids)
        ::Image.joins(:observations)
          .joins("INNER JOIN type_materials on type_materials.collection_object_id = observations.observation_object_id AND observations.observation_object_type = 'CollectionObject'")
          .joins('INNER JOIN otus on otus.taxon_name_id = type_materials.protonym_id')
          .where(otus: {id: otu_ids})
      end

      def otu_facet_type_material(otu_ids)
        ::Image.joins(collection_objects: [type_materials: [protonym: [:otus]]])
          .where(otus: {id: otu_ids})
      end

      def otu_facet_otus(otu_ids)
        ::Image.joins(:depictions).where(depictions: {depiction_object_type: 'Otu', depiction_object_id: otu_ids})
      end

      def otu_facet_collection_objects(otu_ids)
        ::Image.joins(collection_objects: [:taxon_determinations])
          .where(taxon_determinations: {otu_id: otu_ids})
      end

      def otu_facet_collection_object_observations(otu_ids)
        ::Image.joins(:observations)
          .joins('INNER JOIN taxon_determinations on taxon_determinations.biological_collection_object_id = observations.observation_object_id')
          .where(taxon_determinations: {otu_id: otu_ids}, observations: {observation_object_type: 'CollectionObject'})
      end

      def otu_facet_otu_observations(otu_ids)
        ::Image.joins(:observations)
          .where(observations: {observation_object_id: otu_ids, observation_object_type: 'Otu'})
      end

      # @return [Scope]
      def type_material_depictions_facet
        return nil if type_material_depictions.nil?
        ::Image.joins(collection_objects: [:type_materials])
      end

      def build_depiction_facet(kind, ids)
        return nil if ids.empty?
        ::Image.joins(:depictions).where(depictions: {depiction_object_id: ids, depiction_object_type: kind})
      end

      def taxon_name_id_facet
        #  Image -> Depictions -> Otu -> TaxonName -> Ancestors
        return nil if taxon_name_id.empty?

        h = Arel::Table.new(:taxon_name_hierarchies)
        t = ::TaxonName.arel_table

        j1, j2, q1, q2 = nil, nil, nil, nil

        if taxon_name_id_target.include?('Otu')
          a = otu_table.alias('oj1')
          b = t.alias('tj1')
          h_alias = h.alias('th1')

          j1 = table
            .join(depiction_table, Arel::Nodes::InnerJoin).on(table[:id].eq(depiction_table[:image_id]))
            .join(a, Arel::Nodes::InnerJoin).on( depiction_table[:depiction_object_id].eq(a[:id]).and( depiction_table[:depiction_object_type].eq('Otu') ))
            .join(b, Arel::Nodes::InnerJoin).on( a[:taxon_name_id].eq(b[:id]))
            .join(h_alias, Arel::Nodes::InnerJoin).on(b[:id].eq(h_alias[:descendant_id]))

          z = h_alias[:ancestor_id].eq_any(taxon_name_id)
          q1 = ::Image.joins(j1.join_sources).where(z)
        end

        if taxon_name_id_target.include?('CollectionObject')
          a = otu_table.alias('oj2')
          b = t.alias('tj2')
          h_alias = h.alias('th2')

          j2 = table
            .join(depiction_table, Arel::Nodes::InnerJoin).on(table[:id].eq(depiction_table[:image_id]))
            .join(collection_object_table, Arel::Nodes::InnerJoin).on( depiction_table[:depiction_object_id].eq(collection_object_table[:id]).and( depiction_table[:depiction_object_type].eq('CollectionObject') ))
            .join(taxon_determination_table, Arel::Nodes::InnerJoin).on( collection_object_table[:id].eq(taxon_determination_table[:biological_collection_object_id]) )
            .join(a, Arel::Nodes::InnerJoin).on(  taxon_determination_table[:otu_id].eq(a[:id]) )
            .join(b, Arel::Nodes::InnerJoin).on( a[:taxon_name_id].eq(b[:id]))
            .join(h_alias, Arel::Nodes::InnerJoin).on(b[:id].eq(h_alias[:descendant_id]))

          z = h_alias[:ancestor_id].eq_any(taxon_name_id)
          q2 = ::Image.joins(j2.join_sources).where(z)
        end

        if q1 && q2
          ::Image.from("((#{q1.to_sql}) UNION (#{q2.to_sql})) as images")
        elsif q1
          q1.distinct
        else
          q2.distinct
        end
      end

      def query_facets_facet(name = nil)
        return nil if name.nil?

        q = send((name + '_query').to_sym)

        return nil if q.nil?

        n = "query_#{name}_img"

        s = "WITH #{n} AS (" + q.all.to_sql + ') ' +
          ::Image
          .joins(:depictions)
          .joins("JOIN #{n} as #{n}1 on depictions.depiction_object_id = #{n}1.id AND depictions.depiction_object_type = '#{name.treetop_camelize}'")
          .to_sql

        ::Image.from('(' + s + ') as images').distinct
      end

      def merge_clauses
        s = ::Queries::Query::Filter::SUBQUERIES.select{|k,v| v.include?(:image)}.keys.map(&:to_s)
        [
          *s.collect{|m| query_facets_facet(m)}, # Reference all the Image referencing SUBQUERIES
          biocuration_facet,
          collection_object_scope_facet,
          depiction_object_type_facet,
          depictions_facet,
          otu_id_facet,
          otu_scope_facet,
          sled_image_facet,
          sqed_depiction_facet,
          taxon_name_id_facet,
          type_material_depictions_facet,
        ]
      end

    end
  end
end
