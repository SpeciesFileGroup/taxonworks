module Queries
  class Query::Filter < Queries::Query

    SUBQUERIES = {
      taxon_name: [:source],
    }.freeze

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
      
      # TODO: 
      
      SUBQUERIES[filter].each do |k|
        q = (k.to_s + '_query').to_sym
        h.merge! params.permit( q => {} )
      end
  
      # Note, this throws an error:
      # RuntimeError Exception: can't add a new key into hash during iteration
      # h.permit!.to_h.deep_symbolize_keys

      h.permit!.to_hash.deep_symbolize_keys
    end

    # include Queries::Concerns::Identifiers

    # @return [Array]
    attr_accessor :project_id

    def initialize(params)
      @project_id = params[:project_id] || Current.project_id # TODO: revisit
    end

    def project_id
      [@project_id].flatten.compact
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
