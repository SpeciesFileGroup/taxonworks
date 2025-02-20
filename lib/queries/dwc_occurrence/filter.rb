module Queries
  module DwcOccurrence

    # Keep this minimal, in pricinple filtering should be done on the base objects, not the core here.
    class Filter < Query::Filter

      ATTRIBUTES = ::DwcOccurrence.column_names.reject{ |c| %w{
        id project_id created_by_id updated_by_id created_at updated_at
                                                        }.include?(c)}.map(&:to_sym).freeze

      include Queries::Helpers
      include Queries::Concerns::Users
      include Queries::Concerns::Attributes

      PARAMS = [
        *Queries::Concerns::Attributes.params,
        *ATTRIBUTES,
        :dwc_occurrence_id,
        :person_id,
        :taxon_name_id,
        #  :otu_id,

        dwc_occurrence_id: [],
        #   otu_id: [],
        person_id: [],
        taxon_name_id: []
      ].inject([{}]){|ary, k| k.is_a?(Hash) ? ary.last.merge!(k) : ary.unshift(k); ary}.freeze

      # @params dwc_occurrence_id [Integer, Array, nil]
      #   the TW native id, *not* the occurrenceID
      attr_accessor :dwc_occurrence_id

      #  attr_accessor :otu_id
      attr_accessor :person_id
      attr_accessor :taxon_name_id

      def initialize(query_params)
        super

        @dwc_occurrence_id = params[:dwc_occurrence_id]

        #  @otu_id = params[:otu_id]
        @person_id = params[:person_id]
        @taxon_name_id = params[:taxon_name_id]

        set_attributes_params(params)
      end

      def dwc_occurrence_id
        [@dwc_occurrence_id].flatten.compact
      end

      # def otu_id
      #   [@otu_id].flatten.compact
      # end

      def person_id
        [@person_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def dwc_occurrence_id_facet
        return nil if dwc_occurrence_id.empty?
        table[:id].in(dwc_occurrence_id)
      end

      # TODO: these should be referenced through base queries
      # not logic here
      # i.e. ::Queries::CollectionObject::Filter...
      def person_id_facet
        return nil if person_id.empty?

        ::Queries.union(
          ::DwcOccurrence, [
            all_determined_by,
            all_georeferenced_by,
            all_collected_by
          ])
      end

      def all_determined_by
        ::DwcOccurrence
          .joins("JOIN collection_objects co on co.id = dwc_occurrences.dwc_occurrence_object_id AND dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'")
          .joins("JOIN taxon_determinations td on td.taxon_determination_object_id = co.id AND td.taxon_determination_object_type = 'CollectionObject'")
          .joins("JOIN roles r on r.role_object_id = td.id AND r.role_object_type = 'TaxonDetermination' AND r.type = 'Determiner'")
          .where(r: {person_id:})
          .distinct
      end

      def all_georeferenced_by
        ::DwcOccurrence
          .joins("JOIN collection_objects co on co.id = dwc_occurrences.dwc_occurrence_object_id AND dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'")
          .joins('JOIN collecting_events ce on co.collecting_event_id = ce.id')
          .joins('JOIN georeferences g on g.collecting_event_id = ce.id')
          .joins("JOIN roles r on r.role_object_id = g.id AND r.role_object_type = 'Georeference' AND r.type = 'Georeferencer'")
          .where(r: {person_id:})
          .distinct
      end

      def all_collected_by
        ::DwcOccurrence
          .joins("JOIN collection_objects co on co.id = dwc_occurrences.dwc_occurrence_object_id AND dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'")
          .joins('JOIN collecting_events ce on co.collecting_event_id = ce.id')
          .joins("JOIN roles r on r.role_object_id = ce.id AND r.role_object_type = 'CollectingEvent' AND r.type = 'Collector'")
          .where(r: {person_id:})
          .distinct
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        a = ::Queries::DwcOccurrence::Filter.new(
          asserted_distribution_query: {
            taxon_name_query: {
              taxon_name_id:,
              descendants: false, # include self
              synonymify: true } }
        ).all

        b = ::Queries::DwcOccurrence::Filter.new(
          collection_object_query: {
            taxon_name_query: {
              taxon_name_id:,
              descendants: false, # include self
              synonymify: true } }
        ).all

        ::Queries.union(
          ::DwcOccurrence, [ a,b ]
        )
      end

      def asserted_distribution_query_facet
        return nil if asserted_distribution_query.nil?
        s = 'WITH query_ad_dwco AS (' + asserted_distribution_query.all.unscope(:select).select(:id).to_sql + ') ' +
          ::DwcOccurrence
          .select(:id, :dwc_occurrence_object_type, :dwc_occurrence_object_id)
          .joins("JOIN query_ad_dwco as query_ad_dwco1 on dwc_occurrences.dwc_occurrence_object_id = query_ad_dwco1.id
                      AND dwc_occurrences.dwc_occurrence_object_type = 'AssertedDistribution'")
          .to_sql

        ::DwcOccurrence.from('(' + s + ') as dwc_occurrences').distinct
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_dwco AS (' + collection_object_query.all.unscope(:select).select(:id).to_sql + ') ' +
          ::DwcOccurrence
          .select(:id, :dwc_occurrence_object_type, :dwc_occurrence_object_id)
          .joins("JOIN query_co_dwco as query_co_dwco1 on dwc_occurrences.dwc_occurrence_object_id = query_co_dwco1.id
                      AND dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'")
          .to_sql

        ::DwcOccurrence.from('(' + s + ') as dwc_occurrences').distinct
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?
        s = 'WITH query_ce_dwco AS (' + collecting_event_query.all.unscope(:select).select(:id).to_sql + ') ' +
          ::DwcOccurrence
          .select(:id, :dwc_occurrence_object_type, :dwc_occurrence_object_id)
          .joins("JOIN collection_objects co on co.id = dwc_occurrences.dwc_occurrence_object_id AND dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'")
          .joins('JOIN query_ce_dwco as query_ce_dwco1 on co.collecting_event_id = query_ce_dwco1.id')
          .to_sql

        ::DwcOccurrence.from('(' + s + ') as dwc_occurrences').distinct
      end

      def merge_clauses
        [
          asserted_distribution_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          person_id_facet,
          taxon_name_id_facet
        ]
      end

      def and_clauses
        [
          dwc_occurrence_id_facet
        ]
      end
    end
  end
end
