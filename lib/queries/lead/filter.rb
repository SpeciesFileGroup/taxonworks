module Queries
  module Lead

    # Filters keys, i.e. root Leads. Dichotomous (is_virtual false/nil) and
    # simple (is_virtual true) keys are both returned unless is_virtual is set.
    #
    # Facets that reference OTUs (otu_id, otus, otu_query, taxon_name_query)
    # match an OTU anywhere in the key: on the root, on any couplet, or on
    # any LeadItem.
    #
    # Claude (Anthropic) provided > 50% of the code for this class.
    class Filter < Query::Filter

      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Tags

      PARAMS = [
        :description,
        :is_public,
        :is_virtual,
        :lead_id,
        :observation_matrix,
        :observation_matrix_id,
        :otu_id,
        :otus,
        :text,
        :text_exact,

        lead_id: [],
        observation_matrix_id: [],
        otu_id: []
      ].freeze

      # @return [String, nil]
      #   wildcarded match against the root (key) description
      attr_accessor :description

      # @return [Boolean, nil]
      #   true - public keys
      #   false - non-public keys
      #   nil - both
      attr_accessor :is_public

      # @return [Boolean, nil]
      #   true - simple keys
      #   false - dichotomous keys
      #   nil - both
      attr_accessor :is_virtual

      # @return [Array]
      #   ids of root Leads
      attr_accessor :lead_id

      # @return [Boolean, nil]
      #   true - keys built from an observation matrix
      #   false - keys not built from an observation matrix
      #   nil - both
      attr_accessor :observation_matrix

      # @return [Array]
      attr_accessor :observation_matrix_id

      # @return [Array]
      #   keys containing any of these OTUs
      attr_accessor :otu_id

      # @return [Boolean, nil]
      #   true - keys with at least one OTU
      #   false - keys without OTUs
      #   nil - both
      attr_accessor :otus

      # @return [String, nil]
      #   match against the root (key) text, i.e. its title
      attr_accessor :text

      # @return [Boolean, nil]
      attr_accessor :text_exact

      # @param params [Hash]
      def initialize(query_params)
        super

        @description = params[:description]
        @is_public = boolean_param(params, :is_public)
        @is_virtual = boolean_param(params, :is_virtual)
        @lead_id = params[:lead_id]
        @observation_matrix = boolean_param(params, :observation_matrix)
        @observation_matrix_id = params[:observation_matrix_id]
        @otu_id = params[:otu_id]
        @otus = boolean_param(params, :otus)
        @text = params[:text]
        @text_exact = boolean_param(params, :text_exact)

        set_citations_params(params)
        set_data_attributes_params(params)
        set_tags_params(params)
      end

      def lead_id
        [@lead_id].flatten.compact
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      # Always applied, restricts results to keys.
      def root_facet
        table[:parent_id].eq(nil)
      end

      # Base Filter applies `is_public IN (NULL, true)` for api requests; roots
      # always have is_public set, and only true keys are public.
      def api_facet
        return nil unless api
        table[:is_public].eq(true)
      end

      def description_facet
        return nil if description.blank?
        table[:description].matches('%' + description.strip.gsub(/\s+/, '%') + '%')
      end

      def is_public_facet
        return nil if is_public.nil?
        is_public ? table[:is_public].eq(true) : table[:is_public].not_eq(true).or(table[:is_public].eq(nil))
      end

      def is_virtual_facet
        return nil if is_virtual.nil?
        is_virtual ? table[:is_virtual].eq(true) : table[:is_virtual].not_eq(true).or(table[:is_virtual].eq(nil))
      end

      def observation_matrix_facet
        return nil if observation_matrix.nil?
        observation_matrix ? table[:observation_matrix_id].not_eq(nil) : table[:observation_matrix_id].eq(nil)
      end

      def observation_matrix_id_facet
        return nil if observation_matrix_id.empty?
        table[:observation_matrix_id].in(observation_matrix_id)
      end

      def text_facet
        return nil if text.blank?

        if text_exact
          table[:text].eq(text.strip)
        else
          table[:text].matches('%' + text.strip.gsub(/\s+/, '%') + '%')
        end
      end

      def otu_id_facet
        return nil if otu_id.empty?
        keys_with_otus(otu_id)
      end

      def otus_facet
        return nil if otus.nil?

        with_otus = keys_with_otus(::Otu.select(:id))

        if otus
          with_otus
        else
          ::Lead.where.not(id: with_otus.select(:id))
        end
      end

      def otu_query_facet
        return nil if otu_query.nil?
        keys_with_otus(
          ::Otu.from(otu_query.all, :otus).select(:id)
        )
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        keys_with_otus(
          ::Otu.where(taxon_name_id: ::TaxonName.from(taxon_name_query.all, :taxon_names).select(:id)).select(:id)
        )
      end

      def and_clauses
        [
          root_facet,
          api_facet,
          description_facet,
          is_public_facet,
          is_virtual_facet,
          observation_matrix_facet,
          observation_matrix_id_facet,
          text_facet
        ]
      end

      def merge_clauses
        [
          otu_id_facet,
          otus_facet,
          otu_query_facet,
          taxon_name_query_facet
        ]
      end

      private

      # @param otus [Array, ActiveRecord::Relation]
      #   Otu ids, or a relation selecting Otu ids
      # @return [ActiveRecord::Relation]
      #   Leads that are ancestors-or-self of any lead referencing one of
      #   otus, either directly (leads.otu_id) or through a LeadItem
      def keys_with_otus(otus)
        a = ::Lead
          .joins('JOIN lead_hierarchies AS lh_otu ON lh_otu.ancestor_id = leads.id')
          .joins('JOIN leads AS key_leads ON key_leads.id = lh_otu.descendant_id')
          .where(key_leads: { otu_id: otus })

        b = ::Lead
          .joins('JOIN lead_hierarchies AS lh_item ON lh_item.ancestor_id = leads.id')
          .joins('JOIN lead_items AS key_lead_items ON key_lead_items.lead_id = lh_item.descendant_id')
          .where(key_lead_items: { otu_id: otus })

        referenced_klass_union([a, b])
      end

    end
  end
end
