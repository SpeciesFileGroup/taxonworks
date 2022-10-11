module Queries
  module Image
    class Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Identifiers

      # @return [Array]
      #   only return objects with this collecting event ID
      attr_accessor :collecting_event_id

      # @return [Array]
      #    a list of Collection object ids, matches one ot one only
      attr_accessor :collection_object_id

      # @return [Array]
      #    a list of Otu ids, matches one ot one only
      # @param otu_id [Array, Integer]
      #   `otu_id=1` or `otu_id[]=1`
      attr_accessor :otu_id

      # @return [Array]
      # A sub scope of sorts. Purpose is to gather all images
      # possible under an OTU that are of an OTU, CollectionObject or Observation.
      #
      # !! Must be used with an otu_id !!
      # @param otu_scope
      #   options
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

      # @return [Boolean, nil]
      #   true - image is used (in a depiction)
      #   false - image is not used
      #   nil - either
      attr_accessor :depiction

      # @return [Protonym.id, nil]
      #   return all images depicting an Otu that is self or descendant linked
      #   to this TaxonName
      attr_accessor :taxon_name_id

      # @return [Array]
      #   one or both of 'Otu', 'CollectionObject', defaults to both if nothing provided
      # Only used when `ancestor_id` provided
      attr_accessor :ancestor_id_target

      # @return [Array]
      #   depicts some collection objec that is a type specimen
      # attr_accessor :is_type

      # @return [Boolean, nil]
      #   nil = TaxonDeterminations match regardless of current or historical
      #   true = TaxonDetermination must be .current
      #   false = TaxonDetermination must be .historical
      # attr_accessor :current_determinations

      # @param params [Hash]
      def initialize(params)
        params.reject!{ |_k, v| v.nil? || (v == '') } # dump all entries with empty values

        @otu_id = params[:otu_id]
        @otu_scope = params[:otu_scope]&.map(&:to_sym)
        @collection_object_id = params[:collection_object_id]
        @collecting_event_id = params[:collecting_event_id]
        @image_id = params[:image_id]
        @biocuration_class_id = params[:biocuration_class_id]
        @sled_image_id = params[:sled_image_id]
        @sqed_depiction_id = params[:sqed_depiction_id]
        @taxon_name_id = params[:taxon_name_id]
        @ancestor_id_target = params[:ancestor_id_target]

        @depiction = (params[:depiction]&.downcase == 'true' ? true : false) if !params[:depiction].nil?

        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      def taxon_name_id
        [ @taxon_name_id ].flatten.compact
      end

      def ancestor_id_target
        a = [ @ancestor_id_target ].flatten.compact
        a = ['Otu', 'CollectionObject'] if a.empty?
        a
      end

      def biocuration_class_id
        [ @biocuration_class_id ].flatten.compact
      end

      def image_id
        [ @image_id ].flatten.compact
      end

      def otu_id
        [ @otu_id ].flatten.compact
      end

      def otu_scope
        [ @otu_scope ].flatten.compact.map(&:to_sym)
      end

      def collection_object_id
        [ @collection_object_id ].flatten.compact
      end

      def collecting_event_id
        [ @collecting_event_id ].flatten.compact
      end

      def sled_image_id
        [ @sled_image_id ].flatten.compact
      end

      def sqed_depiction_id
        [ @sqed_depiction_id ].flatten.compact
      end

      # @return [Arel::Table]
      def table
        ::Image.arel_table
      end

      # @return [Arel::Table]
      def taxon_determination_table
        ::TaxonDetermination.arel_table
      end

      def base_query
        ::Image.select('images.*')
      end

      # @return [Arel::Table]
      def collecting_event_table
        ::CollectingEvent.arel_table
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
          .where(biocuration_classifications: {biocuration_class_id: biocuration_class_id})
        )
      end

      def depiction_facet
        return nil if depiction.nil?
        subquery = ::Image.joins(:depictions).where(table[:id].eq(depiction_table[:image_id])).arel.exists
        ::Image.where(depiction == true ? subquery : subquery.not)
      end

      # facet
      def type_facet
        return nil if is_type.nil?
        table[:type].eq(collection_object_type)
      end

      def sled_image_facet
        return nil if sled_image_id.empty?
        ::Image.joins(:sled_image).where(sled_images: {id: sled_image_id})
      end

      def sqed_depiction_facet
        return nil if sqed_depiction_id.empty?
        ::Image.joins(depictions: [:sqed_depiction]).where(sqed_depictions: {id: sqed_depiction_id})
      end

      def otu_facet
        return nil if otu_id.empty? || !otu_scope.empty?
        build_depiction_facet('Otu', otu_id)
      end

      def coordinate_otu_ids
        ids = []
        otu_id.each do |id|
          ids += ::Otu.coordinate_otus(id).pluck(:id)
        end
        ids.uniq
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
        clauses = [
          image_facet
        ]

        clauses += [
          #type_facet,
        ]
        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []
        #  clauses += collecting_event_merge_clauses + collecting_event_and_clauses

        clauses += [
          otu_facet,
          otu_scope_facet,
          build_depiction_facet('CollectionObject', collection_object_id),
          build_depiction_facet('CollectingEvent', collecting_event_id),
          #    type_material_facet,
          #    type_material_type_facet,
          ancestors_facet,
          keyword_id_facet,  # See Queries::Concerns::Tags
          created_updated_facet, # See Queries::Concerns::Users
          #   identifier_between_facet,
          #   identifier_facet,
          #   identifier_namespace_facet,
          sqed_depiction_facet,
          sled_image_facet,
          biocuration_facet,
          depiction_facet,
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
          q = ::Image.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::Image.all
        end

        q
      end

      # @return [Scope]
      def type_material_facet
        return nil if type_specimen_taxon_name_id.nil?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and( type_materials_table[:protonym_id].eq(type_specimen_taxon_name_id) )

        ::Image.where(
          ::TypeMaterial.where(w).arel.exists
        )
      end

      # @return [Scope]
      def type_material_type_facet
        return nil if is_type.empty?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and( type_materials_table[:type_type].eq_any(is_type) )

        ::Image.where(
          ::TypeMaterial.where(w).arel.exists
        )
      end

      def image_facet
        return nil if image_id.empty?
        table[:id].eq_any(image_id)
      end

      def build_depiction_facet(kind, ids)
        return nil if ids.empty?
        ::Image.joins(:depictions).where(depictions: {depiction_object_id: ids, depiction_object_type: kind})
      end

      def ancestors_facet
        #  Image -> Depictions -> Otu -> TaxonName -> Ancestors
        return nil if taxon_name_id.empty?

        h = Arel::Table.new(:taxon_name_hierarchies)
        t = ::TaxonName.arel_table

        j1, j2, q1, q2 = nil, nil, nil, nil

        if ancestor_id_target.include?('Otu')
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

        if ancestor_id_target.include?('CollectionObject')
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
          q1
        else
          q2
        end

        #  if validity == true
        #    z = z.and(t[:cached_valid_taxon_name_id].eq(t[:id]))
        #  elsif validity == false
        #    z = z.and(t[:cached_valid_taxon_name_id].not_eq(t[:id]))
        #  end

        # if current_determinations == true
        #   z = z.and(taxon_determination_table[:position].eq(1))
        # elsif current_determinations == false
        #   z = z.and(taxon_determination_table[:position].gt(1))
        # end

      end
    end
  end
end
