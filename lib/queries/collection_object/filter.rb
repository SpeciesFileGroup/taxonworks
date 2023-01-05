require 'queries/collecting_event/filter'
module Queries
  module CollectionObject

    # TODO
    # - use date processing? / DateConcern
    # - syncronize with GIS/GEO

    # Changed:
    # - collecting_event_ids -> collecting_event_id
    # - ancestor_id -> taxon_name_id
    #
    # Added:
    # - descendants

    class Filter < Query::Filter

      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Notes
      include Queries::Concerns::DataAttributes

      # TODO: look for name collisions with CE filter

      # @param [String, nil]
      #    Array or Integer of CollectionObject ids 
      attr_accessor :collection_object_id

      # @param [String, nil]
      #    one of 'Specimen', 'Lot', or 'RangedLot'
      attr_accessor :collection_object_type

      # [Array]
      #   only return objects with these collecting event ID
      attr_accessor :collecting_event_id

      # All params managed by CollectingEvent filter are available here as well
      attr_accessor :collecting_event_query

      # @return [Array, nil]
      #  Otu ids, matches on the TaxonDetermination, see also current_determinations 
      attr_accessor :otu_id

      # @return [Array of Protonym.id, nil]
      #   return all collection objects determined as an Otu that is self or descendant linked
      #   to this TaxonName
      attr_accessor :taxon_name_id

      attr_accessor :descendants

      # @return [Boolean, nil]
      #   nil =  Match against all ancestors, valid or invalid
      #   true = Match against only valid ancestors
      #   false = Match against only invalid ancestors
      attr_accessor :validity

      # @return [Boolean, nil]
      #   nil = TaxonDeterminations match regardless of current or historical
      #   true = TaxonDetermination must be .current
      #   false = TaxonDetermination must be .historical
      attr_accessor :current_determinations

      # @return [True, nil]
      attr_accessor :on_loan

      # @return [True, nil]
      attr_accessor :loaned

      # @return [True, nil]
      attr_accessor :never_loaned

      # @return [Array]
      #   an array of loan_ids, all collection objects inside them will be included
      attr_accessor :loan_id

      # @return [Array]
      #   of biocuration_class ids
      attr_accessor :biocuration_class_ids

      # @return [Array]
      #   of biological_relationship_ids
      attr_accessor :biological_relationship_ids

      # @return [True, False, nil]
      #   true - index is built
      #   false - index is not built
      #   nil - not applied
      attr_accessor :dwc_indexed

      # @return [Protonym#id, nil]
      attr_accessor :type_specimen_taxon_name_id

      # @return [Repository#id, nil]
      attr_accessor :repository_id

      # @return [CurrentRepository#id, nil]
      attr_accessor :current_repository_id

      # @return [Array, nil]
      #  one of `holotype`, `lectotype` etc.
      #   nil - not applied
      attr_accessor :is_type

      # @return [SledImage#id, nil]
      attr_accessor :sled_image_id

      # @return [True, False, nil]
      #   true - index is built
      #   false - index is not built
      #   nil - not applied
      attr_accessor :depictions

      # @return [True, False, nil]
      #   true - has one ore more taxon_determinations
      #   false - does not have any taxon_determinations
      #   nil - not applied
      attr_accessor :taxon_determinations

      # @return [True, False, nil]
      #   true - Otu has taxon name
      #   false - Otu without taxon name
      #   nil - not applied
      attr_accessor :taxon_name

      # @return [True, False, nil]
      #   true - has one ore more georeferences
      #   false - does not have any georeferences
      #   nil - not applied
      attr_accessor :georeferences

      # @param [String, nil]
      #  'true' - order by updated_at
      #  'false', nil - do not apply ordering
      # @return [Boolen, nil]
      attr_accessor :recent

      attr_accessor :object_global_id

      # @return [True, False, nil]
      #   true - has repository_id
      #   false - does not have repository_id
      #   nil - not applied
      attr_accessor :repository

      # @return [True, False, nil]
      #   true - has current_repository_id
      #   false - does not have current_repository_id
      #   nil - not applied
      attr_accessor :current_repository

      # @return [True, False, nil]
      #   true - has preparation_type
      #   false - does not have preparation_type
      #   nil - not applied
      attr_accessor :preparation_type

      # @return [Array]
      attr_accessor :preparation_type_id

      # @return [True, False, nil]
      # @param collecting_event ['true', 'false']
      #   true - has collecting_event_id
      #   false - does not have collecting_event_id
      #   nil - not applied
      attr_accessor :collecting_event

      # @return [True, False, nil]
      #   true - has collecting event that has  geographic_area
      #   false - does not have  collecting event that has geographic area
      #   nil - not applied
      attr_accessor :geographic_area

      # @return [Array]
      # @param determiner [Array or Person#id]
      #   one ore more people id
      attr_accessor :determiner_id

      # @return [Boolean]
      # @param determiner_id_or [String, nil]
      #   `false`, nil - treat ids as "or"
      #   'true' - treat ids as "and" (only collection objects with all and only all will match)
      attr_accessor :determiner_id_or

      # @return [String, nil]
      attr_accessor :buffered_determinations

      # TODO: See `exact[]` pattern in people

      # @return [Boolean, nil]
      attr_accessor :exact_buffered_determinations

      # @return [String, nil]
      attr_accessor :buffered_collecting_event

      # @return [Boolean, nil]
      attr_accessor :exact_buffered_collecting_event

      # @return [Boolean, nil]
      attr_accessor :exact_buffered_other_labels

      # @return [String, nil]
      attr_accessor :buffered_other_labels

      # See Queries::CollectingEvent::Filter
      attr_accessor :collector_id
      attr_accessor :collector_ids_or

      # @return [True, False, nil]
      #   true - has collecting event that has  geographic_area
      #   false - does not have  collecting event that has geographic area
      #   nil - not applied
      attr_accessor :type_material

      # @return [Boolean, nil
      # @param with_buffered_determinations [String, nil]
      #   `false`, nil - without buffered determination field value
      #   'true' - with buffered_determinations field value
      attr_accessor :with_buffered_determinations

      # See with_buffered_determinations
      attr_accessor :with_buffered_collecting_event

      # See with_buffered_determinations
      attr_accessor :with_buffered_other_labels

      # @return String
      # A PostgreSQL valid regular expression. Note that
      # simple strings evaluate as wildcard matches.
      # !! Probably shouldn't expose to external API.
      attr_accessor :determiner_name_regex

      # @param [Hash] args are permitted params
      def initialize(params)
        params.reject!{ |_k, v| v.nil? || (v == '') } # dump all entries with empty values

        # Only CollectingEvent fields are permitted now.
        # (Perhaps) TODO: allow concern attributes nested inside as well, e.g. show me all COs with this Tag on CE.
        collecting_event_params = ::Queries::CollectingEvent::Filter::ATTRIBUTES + ::Queries::CollectingEvent::Filter::PARAMS

        @collecting_event_query = ::Queries::CollectingEvent::Filter.new(
          params.select{|a,b| collecting_event_params.include?(a.to_s) }
        )

        @collection_object_id = params[:collection_object_id]
      
        @taxon_name_id = params[:taxon_name_id]

        @descendants = boolean_param(params, :descendants)

        @biocuration_class_ids = params[:biocuration_class_ids] || []
        @biological_relationship_ids = params[:biological_relationship_ids] || []
        @buffered_collecting_event = params[:buffered_collecting_event]
        @buffered_determinations = params[:buffered_determinations]
        @buffered_other_labels = params[:buffered_other_labels]
        @collecting_event = boolean_param(params, :collecting_event)
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_type = params[:collection_object_type].blank? ? nil : params[:collection_object_type]
        @current_determinations = boolean_param(params, :current_determinations)
        @current_repository = boolean_param(params, :current_repository)
        @current_repository_id = params[:current_repository_id].blank? ? nil : params[:current_repository_id]
        @depictions = boolean_param(params, :depictions)
        @determiner_id = params[:determiner_id]
        @determiner_id_or = boolean_param(params, :determiner_id_or)
        @determiner_name_regex = params[:determiner_name_regex]
        @dwc_indexed = boolean_param(params, :dwc_indexed)
        @exact_buffered_collecting_event = boolean_param(params, :exact_buffered_collecting_event)
        @exact_buffered_determinations = boolean_param(params, :exact_buffered_determinations)
        @exact_buffered_other_labels = boolean_param(params, :exact_buffered_other_labels)
        @geographic_area = boolean_param(params, :geographic_area)
        @georeferences = boolean_param(params, :georeferences)
        @is_type = params[:is_type] || []
        @loaned = boolean_param(params, :loaned)
        @never_loaned = boolean_param(params, :never_loaned)
        @object_global_id = params[:object_global_id]
        @on_loan =  boolean_param(params, :on_loan)
        @loan_id = params[:loan_id]
        @otu_descendants = boolean_param(params, :otu_descendants)
        @otu_id = params[:otu_id]
        @preparation_type_id = params[:preparation_type_id]
        @recent = boolean_param(params, :recent)
        @repository = boolean_param(params, :repository)
        @preparation_type = boolean_param(params, :preparation_type)
        @repository_id = params[:repository_id].blank? ? nil : params[:repository_id]
        @sled_image_id = params[:sled_image_id].blank? ? nil : params[:sled_image_id]
        @taxon_determinations = boolean_param(params, :taxon_determinations)
        @type_material = boolean_param(params, :type_material)
        @type_specimen_taxon_name_id = params[:type_specimen_taxon_name_id].blank? ? nil : params[:type_specimen_taxon_name_id]
        @validity = boolean_param(params, :validity)
        @with_buffered_collecting_event = boolean_param(params, :with_buffered_collecting_event)
        @with_buffered_determinations =  boolean_param(params, :with_buffered_determinations)
        @with_buffered_other_labels = boolean_param(params, :with_buffered_other_labels)

        set_data_attributes_params(params)
        set_identifier(params)
        set_notes_params(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::CollectionObject.arel_table
      end

      def base_query
        ::CollectionObject.select('collection_objects.*')
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
      def type_materials_table
        ::TypeMaterial.arel_table
      end

      # @return [Arel::Table]
      def depiction_table
        ::Depiction.arel_table
      end

      # @return [Arel::Table]
      def taxon_determination_table
        ::TaxonDetermination.arel_table
      end

      def otu_id 
        [@otu_id].flatten.compact
      end

      def collecting_event_id 
        [@collecting_event_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def determiner_id
        [@determiner_id].flatten.compact
      end

      def preparation_type_id
        [@preparation_type_id].flatten.compact
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        table[:id].eq_any(collection_object_id)
      end

      def loan_id
        [@loan_id].flatten.compact
      end

      def taxon_determinations_facet
        return nil if taxon_determinations.nil?

        if taxon_determinations
          ::CollectionObject.joins(:taxon_determinations).distinct
        else
          ::CollectionObject.left_outer_joins(:taxon_determinations)
            .where(taxon_determinations: {id: nil})
            .distinct
        end
      end

      # TODO: DRY with Source (author), TaxonName, etc.
      # See Queries::ColletingEvent::Filter for other use
      def determiner_facet
        return nil if determiner_id.empty?
        tt = table

        o = ::TaxonDetermination.arel_table
        r = ::Role.arel_table

        a = o.alias("a_det__")
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('det_r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('TaxonDetermination'))
          .and(c[:type].eq('Determiner'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(determiner_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(determiner_id.length)) unless determiner_id_or

        b = b.as('det_z1_')

        ::CollectionObject.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['biological_collection_object_id'].eq(tt['id']))))
      end

      def determiner_name_regex_facet
        return nil if determiner_name_regex.nil?
        ::CollectionObject.joins(:determiners).where('people.cached ~* ?',  determiner_name_regex)
      end

      def georeferences_facet
        return nil if georeferences.nil?
        if georeferences
          ::CollectionObject.joins(:georeferences).distinct
        else
          ::CollectionObject.left_outer_joins(:georeferences)
            .where(georeferences: {id: nil})
            .distinct
        end
      end

      def object_global_id_facet
        return nil if object_global_id.nil?

        if o = GlobalID::Locator.locate(object_global_id)
          k = o.class.name
          id = o.id

          table[:id].eq(id).and(table[:type].eq(k))
        else
          nil
        end
      end

      def repository_facet
        return nil if repository.nil?
        if repository
          ::CollectionObject.where.not(repository_id: nil)
        else
          ::CollectionObject.where(repository_id: nil)
        end
      end

      def current_repository_facet
        return nil if current_repository.nil?
        if current_repository
          ::CollectionObject.where.not(current_repository_id: nil)
        else
          ::CollectionObject.where(current_repository_id: nil)
        end
      end

      def preparation_type_facet
        return nil if preparation_type.nil?
        if preparation_type
          ::CollectionObject.where.not(preparation_type_id: nil)
        else
          ::CollectionObject.where(preparation_type_id: nil)
        end
      end

      def collecting_event_facet
        return nil if collecting_event.nil?
        if collecting_event
          ::CollectionObject.where.not(collecting_event_id: nil)
        else
          ::CollectionObject.where(collecting_event_id: nil)
        end
      end

      def with_buffered_collecting_event_facet
        return nil if with_buffered_collecting_event.nil?
        if with_buffered_collecting_event
          ::CollectionObject.where.not(buffered_collecting_event: nil)
        else
          ::CollectionObject.where(buffered_collecting_event: nil)
        end
      end

      def with_buffered_other_labels_facet
        return nil if with_buffered_other_labels.nil?
        if with_buffered_other_labels
          ::CollectionObject.where.not(buffered_other_labels: nil)
        else
          ::CollectionObject.where(buffered_other_labels: nil)
        end
      end

      def with_buffered_determinations_facet
        return nil if with_buffered_determinations.nil?
        if with_buffered_determinations
          ::CollectionObject.where.not(buffered_determinations: nil)
        else
          ::CollectionObject.where(buffered_determinations: nil)
        end
      end

      # This is not spatial
      def geographic_area_facet
        return nil if geographic_area.nil?

        if geographic_area
          ::CollectionObject.joins(:collecting_event).where.not(collecting_events: {geographic_area_id: nil}).distinct
        else
          ::CollectionObject.left_outer_joins(:collecting_event)
            .where(collecting_events: {geographic_area_id: nil})
            .distinct
        end
      end

      def biocuration_facet
        return nil if biocuration_class_ids.empty?
        ::CollectionObject::BiologicalCollectionObject.joins(:biocuration_classifications).where(biocuration_classifications: {biocuration_class_id: biocuration_class_ids})
      end

      def loan_facet
        return nil if loan_id.empty?
        ::CollectionObject::BiologicalCollectionObject.joins(:loans).where(loans: {id: loan_id})
      end

      def type_facet
        return nil if collection_object_type.nil?
        table[:type].eq(collection_object_type)
      end

      def depictions_facet
        return nil if depictions.nil?

        if depictions
          ::CollectionObject.joins(:depictions).distinct
        else
          ::CollectionObject.left_outer_joins(:depictions)
            .where(depictions: {id: nil})
            .distinct
        end
      end

      def sled_image_facet
        return nil if sled_image_id.nil?
        ::CollectionObject::BiologicalCollectionObject.joins(:depictions).where("depictions.sled_image_id = ?", sled_image_id)
      end

      def biological_relationship_ids_facet
        return nil if biological_relationship_ids.empty?
        ::CollectionObject.with_biological_relationship_ids(biological_relationship_ids)
      end

      def loaned_facet
        return nil unless loaned
        ::CollectionObject.loaned
      end

      def never_loaned_facet
        return nil unless never_loaned
        ::CollectionObject.never_loaned
      end

      def on_loan_facet
        return nil unless on_loan
        ::CollectionObject.on_loan
      end

      def dwc_indexed_facet
        return nil if dwc_indexed.nil?
        dwc_indexed ?
          ::CollectionObject.dwc_indexed :
          ::CollectionObject.dwc_not_indexed
      end

      # @return Scope
      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        table[:collecting_event_id].eq_any(collecting_event_id)
      end

      def preparation_type_id_facet
        return nil if preparation_type_id.empty?
        table[:preparation_type_id].eq_any(preparation_type_id)
      end

      def repository_id_facet
        return nil if repository_id.blank?
        table[:repository_id].eq(repository_id)
      end

      def current_repository_id_facet
        return nil if current_repository_id.blank?
        table[:current_repository_id].eq(current_repository_id)
      end

      def collecting_event_merge_clauses
        c = []

        # Convert base and clauses to merge clauses
        collecting_event_query.base_merge_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).merge( i )
        end
        c
      end

      def collecting_event_and_clauses
        c = []

        # Convert base and clauses to merge clauses
        collecting_event_query.base_and_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).where( i )
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
          collection_object_id_facet,
          attribute_exact_facet(:buffered_determinations),
          attribute_exact_facet(:buffered_collecting_event),
          attribute_exact_facet(:buffered_other_labels),
          collecting_event_id_facet,
          preparation_type_id_facet,
          type_facet,
          repository_id_facet,
          current_repository_id_facet,
          object_global_id_facet
        ]
        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []
        clauses += collecting_event_merge_clauses + collecting_event_and_clauses

        clauses += [
          taxon_name_id_facet,
          biocuration_facet,
          biological_relationship_ids_facet,
          collecting_event_facet,
          created_updated_facet,  # See Queries::Concerns::Users
          current_repository_facet,
          data_attribute_predicate_facet,
          data_attribute_value_facet,
          data_attributes_facet,
          depictions_facet,
          determiner_facet,
          determiner_name_regex_facet,
          dwc_indexed_facet,
          geographic_area_facet,
          georeferences_facet,

          # See Queries::Concerns::Identifiers
          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
          identifiers_facet,
          local_identifiers_facet,
          match_identifiers_facet,

          keyword_id_facet,       # See Queries::Concerns::Tags
          loan_facet,
          loaned_facet,
          never_loaned_facet,
          note_text_facet,        # See Queries::Concerns::Notes
          notes_facet,
          on_loan_facet,
          otus_facet,
          preparation_type_facet,
          repository_facet,
          sled_image_facet,
          taxon_determinations_facet,
          type_by_taxon_name_facet,
          type_material_facet,
          type_material_type_facet,
          with_buffered_collecting_event_facet,
          with_buffered_determinations_facet,
          with_buffered_other_labels_facet,
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
          q = ::CollectionObject.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::CollectionObject.all
        end

        # TODO: needs to go, orders mess with chaining.
        q = q.order(updated_at: :desc) if recent
        q
      end

      # @return [Scope]
      def type_by_taxon_name_facet
        return nil if type_specimen_taxon_name_id.nil?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and( type_materials_table[:protonym_id].eq(type_specimen_taxon_name_id) )

        ::CollectionObject.where(
          ::TypeMaterial.where(w).arel.exists
        )
      end

      # @return [Scope]
      def type_material_type_facet
        return nil if is_type.empty?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and( type_materials_table[:type_type].eq_any(is_type) )

        ::CollectionObject.where(
          ::TypeMaterial.where(w).arel.exists
        )
      end

      def type_material_facet
        return nil if type_material.nil?
        if type_material
          ::CollectionObject.joins(:type_materials).distinct
        else
          ::CollectionObject.left_outer_joins(:type_materials)
            .where(type_materials: {id: nil})
            .distinct
        end
      end

      # @return [Scope]
      def otus_facet
        return nil if otu_id.empty?

        w = taxon_determination_table[:biological_collection_object_id].eq(table[:id])
          .and( taxon_determination_table[:otu_id].eq_any(otu_id) )

        if current_determinations
          w = w.and(taxon_determination_table[:position].eq(1))
        elsif current_determinations == false
          w = w.and(taxon_determination_table[:position].gt(1))
        end

        ::CollectionObject.where(
          ::TaxonDetermination.where(w).arel.exists
        )
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact.uniq
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        q = nil
        z = nil

        if descendants

          h = Arel::Table.new(:taxon_name_hierarchies)
          t = ::TaxonName.arel_table

          q = table.join(taxon_determination_table, Arel::Nodes::InnerJoin).on(
            table[:id].eq(taxon_determination_table[:biological_collection_object_id])
          ).join(otu_table, Arel::Nodes::InnerJoin).on(
            taxon_determination_table[:otu_id].eq(otu_table[:id])
          ).join(t, Arel::Nodes::InnerJoin).on(
            otu_table[:taxon_name_id].eq(t[:id])
          ).join(h, Arel::Nodes::InnerJoin).on(
            t[:id].eq(h[:descendant_id])
          )
          z = h[:ancestor_id].eq_any(taxon_name_id)

          if validity == true
            z = z.and(t[:cached_valid_taxon_name_id].eq(t[:id]))
          elsif validity == false
            z = z.and(t[:cached_valid_taxon_name_id].not_eq(t[:id]))
          end

          if current_determinations == true
            z = z.and(taxon_determination_table[:position].eq(1))
          elsif current_determinations == false
            z = z.and(taxon_determination_table[:position].gt(1))
          end

        else
          q = ::CollectionObject.joins(taxon_determinations: [:otu])
                 .where(otus: {taxon_name_id: taxon_name_id})

          if current_determinations
            q = q.where(taxon_determinations: {position: 1})
          end

          return q
        end

        ::CollectionObject.joins(q.join_sources).where(z)
      end


    end
  end
end
