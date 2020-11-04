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
      # attr_accessor :ancestor_id

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
        params.reject!{ |_k, v| v.blank? } # dump all entries with empty values

        # DONE
        @otu_id = params[:otu_id]
        @collection_object_id = params[:collection_object_id]
        @collecting_event_id = params[:collecting_event_id]
        @image_id = params[:image_id]
        @biocuration_class_id = params[:biocuration_class_id]
        @sled_image_id = params[:sled_image_id]
        @sqed_depiction_id = params[:sqed_depiction_id]
     
        @depiction = (params[:depiction]&.downcase == 'true' ? true : false) if !params[:depiction].nil?

        # TODO
        # @ancestor_id = params[:ancestor_id].blank? ? nil : params[:ancestor_id]

        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
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
        ::Image.where(depiction == 'true' ? subquery : subquery.not)
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


      #     def collecting_event_merge_clauses
      #       c = []

      #       # Convert base and clauses to merge clauses
      #       collecting_event_query.base_merge_clauses.each do |i|
      #         c.push ::Image.joins(:collecting_event).merge( i )
      #       end
      #       c
      #     end

      #     def collecting_event_and_clauses
      #       c = []

      #       # Convert base and clauses to merge clauses
      #       collecting_event_query.base_and_clauses.each do |i|
      #         c.push ::Image.joins(:collecting_event).where( i )
      #       end
      #       c
      #     end

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
        #        clauses += collecting_event_merge_clauses + collecting_event_and_clauses

        clauses += [
          build_depiction_facet('Otu', otu_id),
          build_depiction_facet('CollectionObject', collection_object_id),
          build_depiction_facet('CollectingEvent', collecting_event_id),
          #    type_material_facet,
          #    type_material_type_facet,
          #    ancestors_facet,
          matching_keyword_ids,  # See Queries::Concerns::Tags
          created_updated_facet, # See Queries::Concerns::Users
          #    identifier_between_facet,
          #    identifier_facet,
          #    identifier_namespace_facet,
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
        ::Image.joins(:depictions).where(depictions: {depiction_object_id: ids, depiction_object_type:  kind})
      end

      # def ancestors_facet
      #   return nil if ancestor_id.nil?
      #   h = Arel::Table.new(:taxon_name_hierarchies)
      #   t = ::TaxonName.arel_table

      #   q = table.join(taxon_determination_table, Arel::Nodes::InnerJoin).on(
      #     table[:id].eq(taxon_determination_table[:biological_collection_object_id])
      #   ).join(otu_table, Arel::Nodes::InnerJoin).on(
      #     taxon_determination_table[:otu_id].eq(otu_table[:id])
      #   ).join(t, Arel::Nodes::InnerJoin).on(
      #     otu_table[:taxon_name_id].eq(t[:id])
      #   ).join(h, Arel::Nodes::InnerJoin).on(
      #     t[:id].eq(h[:descendant_id])
      #   )

      #   z = h[:ancestor_id].eq(ancestor_id)

      #   if validity == true
      #     z = z.and(t[:cached_valid_taxon_name_id].eq(t[:id]))
      #   elsif validity == false
      #     z = z.and(t[:cached_valid_taxon_name_id].not_eq(t[:id]))
      #   end

      #   if current_determinations == true
      #     z = z.and(taxon_determination_table[:position].eq(1))
      #   elsif current_determinations == false
      #     z = z.and(taxon_determination_table[:position].gt(1))
      #   end

      #   ::Image.joins(q.join_sources).where(z)
      # end

    end
  end
end
