module Queries
  module FieldOccurrence
    class Filter < Query::Filter

      include Queries::Helpers
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Depictions
      include Queries::Concerns::Notes
      include Queries::Concerns::Protocols
      include Queries::Concerns::Tags

      PARAMS = [
        *::Queries::CollectingEvent::Filter::BASE_PARAMS,
        *Queries::Concerns::DateRanges.params, # Fead to CE query. Revisit possibly.

      # :biological_association_id,
      # :biological_associations,
      # :biological_relationship_id,
      # :collecting_event,
       :field_occurrence_id,
      # :collection_object_type,
      # :collectors,
      # :current_determinations,
      # :current_repository,
      # :current_repository_id,
      # :dates,
      # :deaccessioned,
      # :descendants,
      # :determiner_id_or,
      # :determiner_name_regex,
      # :determiners,
      # :dwc_indexed,
      # :extract_id,
      # :georeferences,
      # :import_dataset_id,
      # :repository,
      # :repository_id,
      # :sled_image_id,
      # :spatial_geographic_areas,
      # :taxon_determination_id,
      # :taxon_determinations,
      # :taxon_name_id,
      # :validity,
      # biocuration_class_id: [],
      # biological_association_id: [],
      # biological_relationship_id: [],
      # collecting_event_id: [],
      # field_occurrence_id: [],
      # determiner_id: [],
      # extract_id: [],
      # geographic_area_id: [],
      # import_dataset_id: [],
      # is_type: [],
      # otu_id: [],
      # taxon_name_id: [],
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
      #    Array or Integer of FieldOccurrence ids
      attr_accessor :field_occurrence_id

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
      #  true = FieldOccurrence with deaccessioned_at OR deaccessioned_reason populated or deaccession_recipient.present?
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

      # @return String
      # A PostgreSQL valid regular expression. Note that
      # simple strings evaluate as wildcard matches.
      # !! Probably shouldn't expose to external API.
      attr_accessor :determiner_name_regex

      # @return Array
      #  match all FieldOccurrences that are the origin of these Extracts
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
        @biological_associations = boolean_param(params, :biological_associations)
        @collecting_event = boolean_param(params, :collecting_event)
        @collectors = boolean_param(params, :collectors)
        @collecting_event_id = params[:collecting_event_id]
        @field_occurrence_id = params[:field_occurrence_id]
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
        @extract_id = params[:extract_id]
        @geographic_area = boolean_param(params, :geographic_area)
        @georeferences = boolean_param(params, :georeferences)
        @import_dataset_id = params[:import_dataset_id]
        @is_type = params[:is_type] || []
        @otu_descendants = boolean_param(params, :otu_descendants)
        @otu_id = params[:otu_id]
        @repository = boolean_param(params, :repository)
        @repository_id = params[:repository_id]
        @sled_image_id = (params[:sled_image_id].presence)
        @taxon_determinations = boolean_param(params, :taxon_determinations)
        @taxon_name_id = params[:taxon_name_id]
        @validity = boolean_param(params, :validity)

        set_citations_params(params)
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

      def field_occurrence_id
        [@field_occurrence_id].flatten.compact.uniq
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

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact.uniq
      end

      def repository_id
        [@repository_id].flatten.compact.uniq
      end

      def field_occurrence_id_facet
        return nil if field_occurrence_id.empty?
        table[:id].in(field_occurrence_id)
      end

      def import_dataset_id_facet
        return nil if import_dataset_id.blank?
        ::FieldOccurrence.joins(:related_origin_relationships)
        .where(origin_relationships: {old_object_id: import_dataset_id, old_object_type: 'ImportDataset'})
      end

      def extract_id_facet
        return nil if extract_id.empty?
        ::FieldOccurrence
          .joins(:origin_relationships)
          .where(origin_relationships: { new_object_id: extract_id, new_object_type: 'Extract' })
      end

      def taxon_determinations_facet
        return nil if taxon_determinations.nil?

        if taxon_determinations
          ::FieldOccurrence.joins(:taxon_determinations).distinct
        else
          ::FieldOccurrence.where.missing(:taxon_determinations)
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

        ::FieldOccurrence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['biological_field_occurrence_id'].eq(tt['id']))))
      end

      def determiners_facet
        return nil if determiners.nil?
        if determiners
          ::FieldOccurrence.joins(:determiners)
        else
          ::FieldOccurrence.where.missing(:determiners)
        end
      end

      def collectors_facet
        return nil if collectors.nil?
        if collectors
          ::FieldOccurrence.joins(:collectors)
        else
          ::FieldOccurrence.where.missing(:collectors)
        end
      end

      def determiner_name_regex_facet
        return nil if determiner_name_regex.nil?
        ::FieldOccurrence.joins(:determiners).where('people.cached ~* ?', determiner_name_regex)
      end

      def georeferences_facet
        return nil if georeferences.nil?
        if georeferences
          ::FieldOccurrence.joins(:georeferences).distinct
        else
          ::FieldOccurrence.left_outer_joins(:georeferences)
            .where(georeferences: { id: nil })
            .distinct
        end
      end

      def repository_facet
        return nil if repository.nil?
        if repository
          ::FieldOccurrence.where.not(repository_id: nil)
        else
          ::FieldOccurrence.where(repository_id: nil)
        end
      end

      def current_repository_facet
        return nil if current_repository.nil?
        if current_repository
          ::FieldOccurrence.where.not(current_repository_id: nil)
        else
          ::FieldOccurrence.where(current_repository_id: nil)
        end
      end

      def collecting_event_facet
        return nil if collecting_event.nil?
        if collecting_event
          ::FieldOccurrence.where.not(collecting_event_id: nil)
        else
          ::FieldOccurrence.where(collecting_event_id: nil)
        end
      end

      # This is not spatial
      def geographic_area_facet
        return nil if geographic_area.nil?

        if geographic_area
          ::FieldOccurrence.joins(:collecting_event).where.not(collecting_events: { geographic_area_id: nil }).distinct
        else
          ::FieldOccurrence.left_outer_joins(:collecting_event)
            .where(collecting_events: { geographic_area_id: nil })
            .distinct
        end
      end

      def biocuration_facet
        return nil if biocuration_class_id.empty?
        ::FieldOccurrence::BiologicalFieldOccurrence.joins(:biocuration_classifications)
          .where(biocuration_classifications: { biocuration_class_id: })
      end

      def sled_image_facet
        return nil if sled_image_id.nil?
        ::FieldOccurrence::BiologicalFieldOccurrence.joins(:depictions).where('depictions.sled_image_id = ?', sled_image_id)
      end

      def biological_relationship_id_facet
        return nil if biological_relationship_id.empty?
        ::FieldOccurrence.with_biological_relationship_id(biological_relationship_id)
      end

      def dwc_indexed_facet
        return nil if dwc_indexed.nil?
        dwc_indexed ?
          ::FieldOccurrence.dwc_indexed :
          ::FieldOccurrence.dwc_not_indexed
      end

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        table[:collecting_event_id].in(collecting_event_id)
      end

      def repository_id_facet
        return nil if repository_id.blank?
        table[:repository_id].in(repository_id)
      end

      def current_repository_id_facet
        return nil if current_repository_id.blank?
        table[:current_repository_id].eq(current_repository_id)
      end

      def otu_id_facet
        return nil if otu_id.empty?

        w = taxon_determination_table[:biological_field_occurrence_id].eq(table[:id])
          .and(taxon_determination_table[:otu_id].in(otu_id))

        if current_determinations
          w = w.and(taxon_determination_table[:position].eq(1))
        elsif current_determinations == false
          w = w.and(taxon_determination_table[:position].gt(1))
        end

        ::FieldOccurrence.where(
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
            table[:id].eq(taxon_determination_table[:biological_field_occurrence_id])
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
          q = ::FieldOccurrence.joins(taxon_determinations: [:otu])
            .where(otus: { taxon_name_id: })

          if current_determinations
            q = q.where(taxon_determinations: { position: 1 })
          end

          return q
        end

        ::FieldOccurrence.joins(q.join_sources).where(z).distinct
      end

      def dates_facet
        return nil if dates.nil?
        if dates
          ::FieldOccurrence.left_joins(:collecting_event).where(
            'start_date_year IS NOT NULL OR ' \
            'start_date_month IS NOT NULL OR ' \
            'start_date_day IS NOT NULL OR ' \
            'end_date_year IS NOT NULL OR ' \
            'end_date_month IS NOT NULL OR ' \
            'end_date_day IS NOT NULL OR ' \
            'verbatim_date IS NOT NULL'
          )
        else
          ::FieldOccurrence.left_joins(:collecting_event).where(
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
        a = ::FieldOccurrence.where('(deaccession_reason IS NOT NULL) OR (deaccessioned_at IS NOT NULL)')
        b = ::FieldOccurrence.joins(:deaccession_recipient)

        c = referenced_klass_union([a, b])
        if deaccessioned
          c
        else
          s = 'WITH query_deac AS (' + c.all.to_sql + ') ' +
              ::FieldOccurrence
                .joins('LEFT JOIN query_deac as query_deac1 on query_deac1.id = collection_objects.id')
                .where('query_deac1.id IS NULL').to_sql
          ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
        end
      end

      def base_collecting_event_query_facet
        # Turn project_id off and check for a truly empty query
        base_collecting_event_query.project_id = nil
        return nil if base_collecting_event_query.all(true).nil?

        # Turn project_id back on
        base_collecting_event_query.project_id = project_id

        s = 'WITH query_ce_base_co AS (' + base_collecting_event_query.all.to_sql + ') ' +
            ::FieldOccurrence
              .joins('JOIN query_ce_base_co as query_ce_base_co1 on query_ce_base_co1.id = collection_objects.collecting_event_id')
              .to_sql

        ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
      end

    # def taxon_name_query_facet
    #   return nil if taxon_name_query.nil?
    #   s = 'WITH query_tn_co AS (' + taxon_name_query.all.to_sql + ') ' +
    #       ::FieldOccurrence
    #         .joins(:taxon_names)
    #         .joins('JOIN query_tn_co as query_tn_co1 on query_tn_co1.id = taxon_names.id')
    #         .to_sql

    #   ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
    # end

    # def collecting_event_query_facet
    #   return nil if collecting_event_query.nil?
    #   s = 'WITH query_ce_co AS (' + collecting_event_query.all.to_sql + ') ' +
    #       ::FieldOccurrence
    #         .joins('JOIN query_ce_co as query_ce_co1 on query_ce_co1.id = collection_objects.collecting_event_id')
    #         .to_sql

    #   ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
    # end


#     def otu_query_facet
#       return nil if otu_query.nil?
#       s = 'WITH query_otu_co AS (' + otu_query.all.to_sql + ') ' +
#           ::FieldOccurrence
#             .joins(:taxon_determinations)
#             .joins('JOIN query_otu_co as query_otu_co1 on query_otu_co1.id = taxon_determinations.otu_id')
#             .where(taxon_determinations: { position: 1 })
#             .to_sql

#       ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
#     end

#     def biological_associations_facet
#       return nil if biological_associations.nil?
#       a = ::FieldOccurrence.joins(:biological_associations)
#       b = ::FieldOccurrence.joins(:related_biological_associations)

#       referenced_klass_union([a, b])
#     end

#     # TODO: turn into UNION!
#     def biological_association_id_facet
#       return nil if biological_association_id.empty?
#       b = ::BiologicalAssociation.where(id: biological_association_id)
#       s = 'WITH query_ba_id_co AS (' + b.all.to_sql + ') ' +
#           ::FieldOccurrence
#             .joins("LEFT JOIN query_ba_id_co as query_ba_id_co1 on collection_objects.id = query_ba_id_co1.biological_association_subject_id AND query_ba_id_co1.biological_association_subject_type = 'FieldOccurrence'")
#             .joins("LEFT JOIN query_ba_id_co as query_ba_id_co2 on collection_objects.id = query_ba_id_co2.biological_association_object_id AND query_ba_id_co2.biological_association_object_type = 'FieldOccurrence'")
#             .where('(query_ba_id_co1.id) IS NOT NULL OR (query_ba_id_co2.id IS NOT NULL)')
#             .to_sql

#       ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
#     end

#     # TODO: turn into UNION!
#     def biological_association_query_facet
#       return nil if biological_association_query.nil?
#       s = 'WITH query_ba_co AS (' + biological_association_query.all.to_sql + ') ' +
#           ::FieldOccurrence
#             .joins("LEFT JOIN query_ba_co as query_ba_co1 on collection_objects.id = query_ba_co1.biological_association_subject_id AND query_ba_co1.biological_association_subject_type = 'FieldOccurrence'")
#             .joins("LEFT JOIN query_ba_co as query_ba_co2 on collection_objects.id = query_ba_co2.biological_association_object_id AND query_ba_co2.biological_association_object_type = 'FieldOccurrence'")
#             .where('(query_ba_co1.id) IS NOT NULL OR (query_ba_co2.id IS NOT NULL)')
#             .to_sql

#       ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
#     end

#     def extract_query_facet
#       return nil if extract_query.nil?

#       s = 'WITH query_extract_co AS (' + extract_query.all.to_sql + ') ' +
#           ::FieldOccurrence
#             .joins(:origin_relationships)
#             .joins("JOIN query_extract_co as query_extract_co1 on origin_relationships.new_object_id = query_extract_co1.id and origin_relationships.new_object_type = 'Extract'")
#             .to_sql

#       ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
#     end

#     def observation_query_facet
#       return nil if observation_query.nil?

#       s = 'WITH query_obs_co AS (' + observation_query.all.to_sql + ') ' +
#           ::FieldOccurrence
#             .joins(:observations)
#             .joins('JOIN query_obs_co as query_obs_co1 on observations.id = query_obs_co1.id')
#             .to_sql

#       ::FieldOccurrence.from('(' + s + ') as collection_objects').distinct
#     end

      def and_clauses
        [
          #collecting_event_id_facet,
          field_occurrence_id_facet,
        ]
      end

      def merge_clauses
        [

       #  import_dataset_id_facet,
       #  observation_query_facet,
       #  biological_association_id_facet,
       #  base_collecting_event_query_facet,
       #  biological_association_query_facet,
       #  collecting_event_query_facet,
       #  extract_query_facet,
       #  otu_query_facet,
       #  taxon_name_query_facet,

       #  biocuration_facet,
       #  biological_associations_facet,
       #  biological_relationship_id_facet,
       #  collecting_event_facet,
       #  collectors_facet,
       #  current_repository_facet,
       #  dates_facet,
       #  deaccessioned_facet,
       #  determiner_facet,
       #  determiner_name_regex_facet,
       #  determiners_facet,
       #  dwc_indexed_facet,
       #  extract_id_facet,
       #  geographic_area_facet,
       #  georeferences_facet,
       #  otu_id_facet,
       #  repository_facet,
       #  sled_image_facet,
       #  taxon_determinations_facet,
       #  taxon_name_id_facet,
        ]
      end
    end
  end
end
