module Queries
  module CollectionObject
    class Filter < Query::Filter

      # !! May not include Concerns::Attributes (used by CE)
      include Queries::Helpers
      include Queries::Concerns::Citations
      include Queries::Concerns::Containable
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Depictions
      include Queries::Concerns::Notes
      include Queries::Concerns::Protocols
      include Queries::Concerns::Tags

      PARAMS = [
        *::Queries::CollectingEvent::Filter::BASE_PARAMS,
        *Queries::Concerns::DateRanges.params, # Fead to CE query. Revisit possibly.

        :biological_association_id,
        :biological_associations,
        :biological_relationship_id,
        :buffered_collecting_event,
        :buffered_determinations,
        :buffered_other_labels,
        :collecting_event,
        :collection_object_id,
        :collection_object_type,
        :collectors,
        :current_determinations,
        :current_repository,
        :current_repository_id,
        :dates,
        :deaccessioned,
        :descendants,
        :determiner_id_or,
        :determiner_id,
        :determiner_name_regex,
        :determiners,
        :dwc_indexed,
        :exact_buffered_collecting_event,
        :exact_buffered_determinations,
        :exact_buffered_other_labels,
        :extract_id,
        :georeferences,
        :import_dataset_id,
        :loaned,
        :never_loaned,
        :on_loan,
        :preparation_type,
        :preparation_type_id,
        :repository,
        :repository_id,
        :sled_image_id,
        :spatial_geographic_areas,
        :taxon_determination_id,
        :taxon_determinations,
        :taxon_name_id,
        :type_material,
        :type_specimen_taxon_name_id,
        :validity,
        :with_buffered_collecting_event,
        :with_buffered_determinations,
        :with_buffered_other_labels,
        biocuration_class_id: [],
        biological_association_id: [],
        biological_relationship_id: [],
        collecting_event_id: [],
        collection_object_id: [],
        determiner_id: [],
        extract_id: [],
        geographic_area_id: [],
        import_dataset_id: [],
        is_type: [],
        loan_id: [],
        otu_id: [],
        preparation_type_id: [],
        taxon_name_id: [],
      ].inject([{}]) { |ary, k| k.is_a?(Hash) ? ary.last.merge!(k) : ary.unshift(k); ary }.freeze


      # @return [Array]
      #   of ImportDataset ids
      attr_accessor :import_dataset_id

      # @return [True, False, nil]
      #   true - has collecting event that has  geographic_area
      #   false - does not have  collecting event that has geographic area
      #   nil - not applied
      attr_accessor :biological_associations

      # @return Array
      #   Matching records in this BiologicalAssociation
      attr_accessor :biological_association_id

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
      attr_accessor :base_collecting_event_query

      # @param [Array]
      # @return [Array, nil]
      #  Otu ids, matches on the TaxonDetermination, see also current_determinations
      attr_accessor :otu_id

      # @return [Array of Protonym.id, nil]
      #   return all collection objects determined as an Otu that is self or descendant linked
      #   to this TaxonName
      attr_accessor :taxon_name_id

      attr_accessor :descendants

      # @return [Boolean, nil]
      #  nil = Ignored
      #  true = CollectionObject with deaccessioned_at OR deaccessioned_reason populated or deaccession_recipient.present?
      #  false = without true
      attr_accessor :deaccessioned

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

      # @return [Boolean, nil]
      #  true - A determiner role exists
      #  false - No determiner role exists
      #  nil - not applied
      attr_accessor :determiners

      # @return [Boolean, nil]
      #  true - A collector role exists
      #  false - A collector role exists
      #  nil - not applied
      attr_accessor :collectors

      # @param on_loan [True]
      #   true - the CollectionObject *currently* on loan
      attr_accessor :on_loan

      # @param loaned [True]
      #   true - the CollectionObject has been loaned at least once
      attr_accessor :loaned

      # @param never_loaned [True]
      #   true - the CollectionObject has never been loaned
      attr_accessor :never_loaned

      # @return [Array]
      #   a list of loan#id, all collection objects inside them will be included
      attr_accessor :loan_id

      # @return [Array]
      #   of biocuration_class ids
      attr_accessor :biocuration_class_id

      # @return [Array]
      #   of biological_relationship#id
      attr_accessor :biological_relationship_id

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
      #   `false`, nil - treat the ids in determiner_id as "or"
      #   'true' - treat the ids in determiner_id as "and" (only collection objects with all and only all will match)
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

      # @return Array
      #  match all CollectionObjects that are the origin of these Extracts
      attr_accessor :extract_id

      # @return Boolean
      #    true - any of start/end date or verbatim date are populated
      #    false - none of start/end date or verbatim date are populated
      #    nil - ignored
      attr_accessor :dates

      # rubocop:disable Metric/MethodLength
      def initialize(query_params)
        super

        # Only CollectingEvent fields are permitted, for advanced nesting (e.g. tags on CEs), use collecting_event_query
        collecting_event_params = ::Queries::CollectingEvent::Filter.base_params + Queries::Concerns::DateRanges.params

        # project_id is handled during use
        @base_collecting_event_query = ::Queries::CollectingEvent::Filter.new(
          params.select{ |a, b| collecting_event_params.include?(a) } # maintain this to avoid sub query initialization for now
        )

        @biological_association_id = params[:biological_association_id]
        @biocuration_class_id = params[:biocuration_class_id]
        @biological_relationship_id = params[:biological_relationship_id] # TODO: no reference?
        @buffered_collecting_event = params[:buffered_collecting_event]
        @buffered_determinations = params[:buffered_determinations]
        @buffered_other_labels = params[:buffered_other_labels]
        @biological_associations = boolean_param(params, :biological_associations)
        @collecting_event = boolean_param(params, :collecting_event)
        @collectors = boolean_param(params, :collectors)
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_id = params[:collection_object_id]
        @collection_object_type = params[:collection_object_type].presence
        @current_determinations = boolean_param(params, :current_determinations)
        @current_repository = boolean_param(params, :current_repository)
        @current_repository_id = params[:current_repository_id].presence
        @dates = boolean_param(params, :dates)
        @descendants = boolean_param(params, :descendants)
        @deaccessioned = boolean_param(params, :deaccessioned)
        @determiners = boolean_param(params, :determiners)
        @determiner_id = params[:determiner_id]
        @determiner_id_or = boolean_param(params, :determiner_id_or)
        @determiner_name_regex = params[:determiner_name_regex]
        @dwc_indexed = boolean_param(params, :dwc_indexed)
        @exact_buffered_collecting_event = boolean_param(params, :exact_buffered_collecting_event)
        @exact_buffered_determinations = boolean_param(params, :exact_buffered_determinations)
        @exact_buffered_other_labels = boolean_param(params, :exact_buffered_other_labels)
        @extract_id = params[:extract_id]
        @geographic_area = boolean_param(params, :geographic_area)
        @georeferences = boolean_param(params, :georeferences)
        @import_dataset_id = params[:import_dataset_id]
        @is_type = params[:is_type] || []
        @loan_id = params[:loan_id]
        @loaned = boolean_param(params, :loaned)
        @never_loaned = boolean_param(params, :never_loaned)
        @on_loan = boolean_param(params, :on_loan)
        @otu_descendants = boolean_param(params, :otu_descendants)
        @otu_id = params[:otu_id]
        @preparation_type = boolean_param(params, :preparation_type)
        @preparation_type_id = params[:preparation_type_id]
        @repository = boolean_param(params, :repository)
        @repository_id = params[:repository_id]
        @sled_image_id = (params[:sled_image_id].presence)
        @taxon_determinations = boolean_param(params, :taxon_determinations)
        @taxon_name_id = params[:taxon_name_id]
        @type_material = boolean_param(params, :type_material)
        @type_specimen_taxon_name_id = (params[:type_specimen_taxon_name_id].presence)
        @validity = boolean_param(params, :validity)
        @with_buffered_collecting_event = boolean_param(params, :with_buffered_collecting_event)
        @with_buffered_determinations = boolean_param(params, :with_buffered_determinations)
        @with_buffered_other_labels = boolean_param(params, :with_buffered_other_labels)

        set_citations_params(params)
        set_containable_params(params)
        set_data_attributes_params(params)
        set_depiction_params(params)
        set_notes_params(params)
        set_protocols_params(params)
        set_tags_params(params)
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
      def taxon_determination_table
        ::TaxonDetermination.arel_table
      end

      def biological_association_id
        [@biological_association_id].flatten.compact.uniq
      end

      def biocuration_class_id
        [@biocuration_class_id].flatten.compact.uniq
      end

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact.uniq
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact.uniq
      end

      def collection_object_id
        [@collection_object_id].flatten.compact.uniq
      end

      def determiner_id
        [@determiner_id].flatten.compact.uniq
      end

      def extract_id
        [@extract_id].flatten.compact.uniq
      end

      def import_dataset_id
        [@import_dataset_id].flatten.compact
      end

      def loan_id
        [@loan_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def preparation_type_id
        [@preparation_type_id].flatten.compact.uniq
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact.uniq
      end

      def repository_id
        [@repository_id].flatten.compact.uniq
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        table[:id].in(collection_object_id)
      end

      def import_dataset_id_facet
        return nil if import_dataset_id.blank?
        ::CollectionObject.joins(:related_origin_relationships)
          .where(origin_relationships: {old_object_id: import_dataset_id, old_object_type: 'ImportDataset'})
      end

      def extract_id_facet
        return nil if extract_id.empty?
        ::CollectionObject
          .joins(:origin_relationships)
          .where(origin_relationships: { new_object_id: extract_id, new_object_type: 'Extract' })
      end

      def taxon_determinations_facet
        return nil if taxon_determinations.nil?

        if taxon_determinations
          ::CollectionObject.joins(:taxon_determinations).distinct
        else
          ::CollectionObject.where.missing(:taxon_determinations)
        end
      end

      # TODO: DRY with Source (author), TaxonName, etc.
      # See Queries::ColletingEvent::Filter for other use
      def determiner_facet
        return nil if determiner_id.empty?
        tt = table

        o = ::TaxonDetermination.arel_table
        r = ::Role.arel_table

        a = o.alias('a_det__')
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('det_r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('TaxonDetermination'))
          .and(c[:type].eq('Determiner'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].in(determiner_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(determiner_id.length)) unless determiner_id_or

        b = b.as('det_z1_')

        ::CollectionObject.joins(Arel::Nodes::InnerJoin.new(b,
        Arel::Nodes::On.new( b['taxon_determination_object_id'].eq(tt['id']).and( b['taxon_determination_object_type'].eq('CollectionObject') )
        )))
      end

      def determiners_facet
        return nil if determiners.nil?
        if determiners
          ::CollectionObject.joins(:determiners)
        else
          ::CollectionObject.where.missing(:determiners)
        end
      end

      def collectors_facet
        return nil if collectors.nil?
        if collectors
          ::CollectionObject.joins(:collectors)
        else
          ::CollectionObject.where.missing(:collectors)
        end
      end

      def determiner_name_regex_facet
        return nil if determiner_name_regex.nil?
        ::CollectionObject.joins(:determiners).where('people.cached ~* ?', determiner_name_regex)
      end

      def georeferences_facet
        return nil if georeferences.nil?
        if georeferences
          ::CollectionObject.joins(:georeferences).distinct
        else
          ::CollectionObject.left_outer_joins(:georeferences)
            .where(georeferences: { id: nil })
            .distinct
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
          ::CollectionObject.joins(:collecting_event).where.not(collecting_events: { geographic_area_id: nil }).distinct
        else
          ::CollectionObject.left_outer_joins(:collecting_event)
            .where(collecting_events: { geographic_area_id: nil })
            .distinct
        end
      end

      def biocuration_facet
        return nil if biocuration_class_id.empty?
        ::CollectionObject::BiologicalCollectionObject.joins(:biocuration_classifications)
          .where(biocuration_classifications: { biocuration_class_id: })
      end

      def loan_facet
        return nil if loan_id.empty?
        ::CollectionObject::BiologicalCollectionObject.joins(:loans).where(loans: { id: loan_id })
      end

      def type_facet
        return nil if collection_object_type.nil?
        table[:type].eq(collection_object_type)
      end

      def sled_image_facet
        return nil if sled_image_id.nil?
        ::CollectionObject::BiologicalCollectionObject.joins(:depictions).where('depictions.sled_image_id = ?', sled_image_id)
      end

      def biological_relationship_id_facet
        return nil if biological_relationship_id.empty?
        ::CollectionObject.with_biological_relationship_id(biological_relationship_id)
      end

      def loaned_facet
        return nil unless loaned
        ::CollectionObject.loaned
      end

      def never_loaned_facet
        return nil unless never_loaned
        ::CollectionObject.never_loaned
      end

      # TODO: change to not/on
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

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        table[:collecting_event_id].in(collecting_event_id)
      end

      def preparation_type_id_facet
        return nil if preparation_type_id.empty?
        table[:preparation_type_id].in(preparation_type_id)
      end

      def repository_id_facet
        return nil if repository_id.blank?
        table[:repository_id].in(repository_id)
      end

      def current_repository_id_facet
        return nil if current_repository_id.blank?
        table[:current_repository_id].eq(current_repository_id)
      end

      def type_by_taxon_name_facet
        return nil if type_specimen_taxon_name_id.nil?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and(type_materials_table[:protonym_id].eq(type_specimen_taxon_name_id))

        ::CollectionObject.where(
          ::TypeMaterial.where(w).arel.exists
        )
      end

      def type_material_type_facet
        return nil if is_type.empty?

        w = type_materials_table[:collection_object_id].eq(table[:id])
          .and(type_materials_table[:type_type].in(is_type))

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
            .where(type_materials: { id: nil })
            .distinct
        end
      end

      def otu_id_facet
        return nil if otu_id.empty?

        w = taxon_determination_table[:taxon_determination_object_id].eq(table[:id])
          .and(taxon_determination_table[:otu_id].in(otu_id))
          .and(taxon_determination_table[:taxon_determination_object_type].eq('CollectionObject'))

        if current_determinations
          w = w.and(taxon_determination_table[:position].eq(1))
        elsif current_determinations == false
          w = w.and(taxon_determination_table[:position].gt(1))
        end

        ::CollectionObject.where(
          ::TaxonDetermination.where(w).arel.exists
        )
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        q = nil
        z = nil

        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          t = ::TaxonName.arel_table

          q = table.join(taxon_determination_table, Arel::Nodes::InnerJoin).on(
            table[:id].eq(taxon_determination_table[:taxon_determination_object_id])
            .and(taxon_determination_table[:taxon_determination_object_type]).eq('CollectionObject')
          ).join(otu_table, Arel::Nodes::InnerJoin).on(
            taxon_determination_table[:otu_id].eq(otu_table[:id])
          ).join(t, Arel::Nodes::InnerJoin).on(
            otu_table[:taxon_name_id].eq(t[:id])
          ).join(h, Arel::Nodes::InnerJoin).on(
            t[:id].eq(h[:descendant_id])
          )
          z = h[:ancestor_id].in(taxon_name_id)

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
            .where(otus: { taxon_name_id: })

          if current_determinations
            q = q.where(taxon_determinations: { position: 1 })
          end

          return q
        end

        ::CollectionObject.joins(q.join_sources).where(z).distinct
      end

      def dates_facet
        return nil if dates.nil?
        if dates
          ::CollectionObject.left_joins(:collecting_event).where(
            'start_date_year IS NOT NULL OR ' \
            'start_date_month IS NOT NULL OR ' \
            'start_date_day IS NOT NULL OR ' \
            'end_date_year IS NOT NULL OR ' \
            'end_date_month IS NOT NULL OR ' \
            'end_date_day IS NOT NULL OR ' \
            'verbatim_date IS NOT NULL'
          )
        else
          ::CollectionObject.left_joins(:collecting_event).where(
            collecting_event: {
              start_date_year: nil,
              start_date_month: nil,
              start_date_day: nil,
              end_date_year: nil,
              end_date_month: nil,
              end_date_day: nil,
              verbatim_date: nil,
            },
          )
        end
      end

      def deaccessioned_facet
        return nil if deaccessioned.nil?
        a = ::CollectionObject.where('(deaccession_reason IS NOT NULL) OR (deaccessioned_at IS NOT NULL)')
        b = ::CollectionObject.joins(:deaccession_recipient)

        c = referenced_klass_union([a, b])
        if deaccessioned
          c
        else
          s = 'WITH query_deac AS (' + c.all.to_sql + ') ' +
            ::CollectionObject
            .joins('LEFT JOIN query_deac as query_deac1 on query_deac1.id = collection_objects.id')
            .where('query_deac1.id IS NULL').to_sql
          ::CollectionObject.from('(' + s + ') as collection_objects').distinct
        end
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_tn_co AS (' + taxon_name_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins(:taxon_names)
          .joins('JOIN query_tn_co as query_tn_co1 on query_tn_co1.id = taxon_names.id')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?
        s = 'WITH query_ce_co AS (' + collecting_event_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins('JOIN query_ce_co as query_ce_co1 on query_ce_co1.id = collection_objects.collecting_event_id')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def loan_query_facet
        return nil if loan_query.nil?
        s = 'WITH query_loan_co AS (' + loan_query.all.to_sql + ') ' +
          ::CollectionObject.joins(:loan_items)
          .joins('JOIN query_loan_co as query_loan_co1 on query_loan_co1.id = loan_items.loan_id')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def base_collecting_event_query_facet
        # Turn project_id off and check for a truly empty query
        base_collecting_event_query.project_id = nil
        return nil if base_collecting_event_query.all(true).nil?

        # Turn project_id back on
        base_collecting_event_query.project_id = project_id

        s = 'WITH query_ce_base_co AS (' + base_collecting_event_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins('JOIN query_ce_base_co as query_ce_base_co1 on query_ce_base_co1.id = collection_objects.collecting_event_id')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_co AS (' + otu_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins(:taxon_determinations)
          .joins('JOIN query_otu_co as query_otu_co1 on query_otu_co1.id = taxon_determinations.otu_id')
          .where(taxon_determinations: { position: 1 })
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def biological_associations_facet
        return nil if biological_associations.nil?
        a = ::CollectionObject.joins(:biological_associations)
        b = ::CollectionObject.joins(:related_biological_associations)

        referenced_klass_union([a, b])
      end

      # TODO: turn into UNION!
      def biological_association_id_facet
        return nil if biological_association_id.empty?
        b = ::BiologicalAssociation.where(id: biological_association_id)
        s = 'WITH query_ba_id_co AS (' + b.all.to_sql + ') ' +
          ::CollectionObject
          .joins("LEFT JOIN query_ba_id_co as query_ba_id_co1 on collection_objects.id = query_ba_id_co1.biological_association_subject_id AND query_ba_id_co1.biological_association_subject_type = 'CollectionObject'")
          .joins("LEFT JOIN query_ba_id_co as query_ba_id_co2 on collection_objects.id = query_ba_id_co2.biological_association_object_id AND query_ba_id_co2.biological_association_object_type = 'CollectionObject'")
          .where('(query_ba_id_co1.id) IS NOT NULL OR (query_ba_id_co2.id IS NOT NULL)')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      # TODO: turn into UNION!
      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_ba_co AS (' + biological_association_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins("LEFT JOIN query_ba_co as query_ba_co1 on collection_objects.id = query_ba_co1.biological_association_subject_id AND query_ba_co1.biological_association_subject_type = 'CollectionObject'")
          .joins("LEFT JOIN query_ba_co as query_ba_co2 on collection_objects.id = query_ba_co2.biological_association_object_id AND query_ba_co2.biological_association_object_type = 'CollectionObject'")
          .where('(query_ba_co1.id) IS NOT NULL OR (query_ba_co2.id IS NOT NULL)')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def extract_query_facet
        return nil if extract_query.nil?

        s = 'WITH query_extract_co AS (' + extract_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins(:origin_relationships)
          .joins("JOIN query_extract_co as query_extract_co1 on origin_relationships.new_object_id = query_extract_co1.id and origin_relationships.new_object_type = 'Extract'")
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def observation_query_facet
        return nil if observation_query.nil?

        s = 'WITH query_obs_co AS (' + observation_query.all.to_sql + ') ' +
          ::CollectionObject
          .joins(:observations)
          .joins('JOIN query_obs_co as query_obs_co1 on observations.id = query_obs_co1.id')
          .to_sql

        ::CollectionObject.from('(' + s + ') as collection_objects').distinct
      end

      def housekeeping_extensions
        [
          housekeeping_extension_query(target: ::CollectingEvent, joins: [:collecting_event]),
          housekeeping_extension_query(target: ::TaxonDetermination, joins: [:taxon_determinations]),
          housekeeping_extension_query(target: ::DataAttribute, joins: [:data_attributes]),
          housekeeping_extension_query(target: ::Georeference, joins: [:georeferences]),
          housekeeping_extension_query(target: ::DataAttribute, joins: {collecting_event: [:data_attributes]}),
          housekeeping_extension_query(target: ::DataAttribute, joins: {collecting_event: [:data_attributes]}),
          housekeeping_extension_query(target: ::Note, joins: {collecting_event: [:notes]}),
          housekeeping_extension_query(target: ::Note, joins: [:notes]),
          housekeeping_extension_query(target: ::Role, joins: [:roles]),
          housekeeping_extension_query(target: ::Role, joins: {collecting_event: [:roles]}),
          housekeeping_extension_query(target: ::Role, joins: { taxon_determinations: [:determiner_roles]}),
        ]
      end

      def and_clauses
        [
          attribute_exact_facet(:buffered_collecting_event),
          attribute_exact_facet(:buffered_determinations),
          attribute_exact_facet(:buffered_other_labels),
          collecting_event_id_facet,
          collection_object_id_facet,
          current_repository_id_facet,
          preparation_type_id_facet,
          repository_id_facet,
          type_facet,
        ]
      end

      def merge_clauses
        [

          import_dataset_id_facet,
          observation_query_facet,
          biological_association_id_facet,
          base_collecting_event_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          extract_query_facet,
          loan_query_facet,
          otu_query_facet,
          taxon_name_query_facet,

          biocuration_facet,
          biological_associations_facet,
          biological_relationship_id_facet,
          collecting_event_facet,
          collectors_facet,
          current_repository_facet,
          dates_facet,
          deaccessioned_facet,
          determiner_facet,
          determiner_name_regex_facet,
          determiners_facet,
          dwc_indexed_facet,
          extract_id_facet,
          geographic_area_facet,
          georeferences_facet,
          loan_facet,
          loaned_facet,
          never_loaned_facet,
          on_loan_facet,
          otu_id_facet,
          preparation_type_facet,
          repository_facet,
          sled_image_facet,
          taxon_determinations_facet,
          taxon_name_id_facet,
          type_by_taxon_name_facet,
          type_material_facet,
          type_material_type_facet,
          with_buffered_collecting_event_facet,
          with_buffered_determinations_facet,
          with_buffered_other_labels_facet,
        ]
      end
      end
      end
      end
