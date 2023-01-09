module Queries
  class Query::Filter < Queries::Query

    # https://github.com/SpeciesFileGroup/taxonworks/blob/2652_unified_filters/app/javascript/vue/components/radials/filter/constants/queryParam.js
    # https://github.com/SpeciesFileGroup/taxonworks/blob/2652_unified_filters/app/javascript/vue/components/radials/filter/constants/filterLinks.js
    # https://github.com/SpeciesFileGroup/taxonworks/tree/2652_unified_filters/app/javascript/vue/components/radials/filter/links
    # https://github.com/SpeciesFileGroup/taxonworks/blob/2652_unified_filters/app/javascript/vue/components/radials/filter/links/CollectionObject.js

    # 
    # !! This is cross-referenced in app/views/javascript/vue/components/radials/filter/links/*.js models.
    # !! When you add a reference here, ensure corresponding js model is aligned.
    # 
    # This is read as  :too <- [:from1, from1] ].
    SUBQUERIES = {
      taxon_name: [:source, :collection_object],
      otu: [:taxon_name],
      collection_object: [:taxon_name],
      collecting_event: [:collection_object]
    }.freeze

    # include Queries::Concerns::Identifiers

    # @return [Array]
    attr_accessor :project_id

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :taxon_name_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :collection_object_query

    # @return [Query::CollectingEvent::Filter, nil]
    attr_accessor :collecting_event_query

    def initialize(params)
      @project_id = params[:project_id] || Current.project_id # TODO: revisit

      if params[:taxon_name_query].present?
        @taxon_name_query = ::Queries::TaxonName::Filter.new(params[:taxon_name_query])
        @taxon_name_query.project_id = project_id
      end

      if params[:collection_object_query].present?
        @collection_object_query = ::Queries::CollectionObject::Filter.new(params[:collection_object_query])
        @collection_object_query.project_id = project_id
      end

      if params[:collecting_event_query].present?
        @collecting_event_query = ::Queries::CollectionEvent::Filter.new(params[:collecting_event_query])
        @collecting_event_query.project_id = project_id
      end

    end

    def project_id
      [@project_id].flatten.compact
    end

    # @params base Symbol
    #   The name of the filter, must match a key in Query::Filter::SUBQUERIES
    #   See /lib/queries/query/filter.rb
    # @params params ActionController::Parameters
    # @return [Hash]
    #   all params for this base request
    #   keys are symbolized
    #
    #  This may all be overkill, since we assign individual values from a hash
    #  one at a time, and we are not writing with params we could replace all
    #  of this with simply params.permit!
    #
    #a The question is whether there are benefits to housekeeping
    # (knowing the expected/full list of params ).  For example using permit
    # tells us when the UI is sending params that we don't expect (not permitted logs).
    #
    # Keeping tack of the list or params in one places also helps to build API documentation.
    #
    # It should let us inject concern attributes as well (but again, the permit level is olikely overkill).
    #
    def self.deep_permit(filter, params)
      h = ActionController::Parameters.new
      h.merge! base_params(params)

      # TODO: consider adding concern params dynamically here

      SUBQUERIES[filter].each do |k|
        q = (k.to_s + '_query').to_sym
        h.merge! params.permit( q => {} )
      end

      # Note, this throws an error:
      # RuntimeError Exception: can't add a new key into hash during iteration
      # h.permit!.to_h.deep_symbolize_keys

      h.permit!.to_hash.deep_symbolize_keys
    end

    # generic multi-use bits
    #   table is defined in each query, it is the class of instances being returned

    # params attribute [Symbol]
    #   a facet for use when params include `author`, and `exact_author` pattern combinations
    #   See queries/source/filter.rb for example use
    #   See /spec/lib/queries/source/filter_spec.rb
    #  !! Whitespace (e.g. tabs, newlines) is ignored when exact is used !!!
    def attribute_exact_facet(attribute = nil)
      a = attribute.to_sym
      return nil if send(a).blank?
      if send("exact_#{a}".to_sym)

        v = send(a)
        v.gsub!(/\s+/, ' ')
        v = ::Regexp.escape(v)
        v.gsub!(/\\\s+/, '\s*') # spaces are escaped, but we need to expand them in case we dont' get them caught
        v = '^\s*' + v + '\s*$'

        # !! May need to add table name here preceeding a.
        Arel::Nodes::SqlLiteral.new( "#{a} ~ '#{v}'" )
      else
        table[a].matches('%' + send(a).strip.gsub(/\s+/, '%') + '%')
      end
    end

    # @return [Arel::Nodes::TableAlias]
    # def parent
    #   table.alias
    # end
  end
end
