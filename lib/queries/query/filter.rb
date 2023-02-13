module Queries

  # Overview
  #
  # This class manages params and nesting of filter queries.
  #
  # Each inheriting class defines a PARAMS variable.
  # Each concern defines `self.params`.
  # Together these two lists are used to compose a list of
  # acceptable params, dynamically, based on the nature
  # of the nested queries.
  #
  # Test coverage is currently in /spec/lib/queries/otu/filter_spec.rb.
  #
  class Query::Filter < Queries::Query

    # Concerns have corresponding Facets in Vue.
    # To add the corresponding facet:
    # In the corresponding FilterVue.vue
    # E.g. `app/javascript/vue/tasks/otu/filter/components/FilterVue.vue`
    #
    # 1- Import the facet:
    #
    # `import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'`
    #
    #  2- Add it to the layout in the position you want it to appear:
    #
    # `<FacetUsers v-model="params" />`
    #
    include Queries::Concerns::Users
    # include Queries::Concerns::Identifiers # Presently in Queries for other use in autocompletes

    #
    # !! SUBQUERIES is cross-referenced in app/views/javascript/vue/components/radials/filter/links/*.js models.
    # !! When you add a reference here, ensure corresponding js model is aligned. There are tests that will catch if they are not.
    #
    # For example:
    # https://github.com/SpeciesFileGroup/taxonworks/app/javascript/vue/components/radials/filter/constants/queryParam.js
    # https://github.com/SpeciesFileGroup/taxonworks/app/javascript/vue/components/radials/filter/constants/filterLinks.js
    # https://github.com/SpeciesFileGroup/taxonworks/app/javascript/vue/components/radials/filter/links/CollectionObject.js
    #
    # You may also need a reference in
    # app/javascript/vue/routes/routes.js
    # app/javascript/vue/components/radials/linker/links
    #
    # This is read as  :to <- [:from1, from2...] ].
    SUBQUERIES = {
      asserted_distribution: [:source, :otu, :biological_association, :taxon_name],
      biological_association: [:source, :collecting_event, :otu, :collection_object, :taxon_name],
      collecting_event: [:source, :collection_object, :biological_association, :otu, :image, :taxon_name],
      collection_object: [:source, :otu, :taxon_name, :collecting_event, :biological_association, :extract, :image, :observation],
      content: [:source, :otu, :taxon_name, :image],
      descriptor: [:source, :observation, :otu],
      extract: [:source, :otu, :collection_object],
      image: [:content, :collection_object, :collecting_event, :otu, :observation, :source, :taxon_name ],
      loan: [:collection_object, :otu],
      observation: [:collection_object, :descriptor, :image, :otu, :source, :taxon_name],
      otu: [:asserted_distribution, :biological_association, :collection_object, :collecting_event, :content, :descriptor, :extract, :image, :loan, :observation, :source, :taxon_name ],
      person: [],
      source: [:asserted_distribution,  :biological_association, :collecting_event, :collection_object, :content, :descriptor, :extract, :image, :observation, :otu, :taxon_name],
      taxon_name: [:asserted_distribution, :biological_association, :collection_object, :collecting_event, :image, :otu, :source ]
    }.freeze

    # @return [Hash]
    #  only referenced in specs
    def self.inverted_subqueries
      r = {}
      SUBQUERIES.each do |k,v|
        v.each do |m|
          if r[m]
            r[m].push k
          else
            r[m] = [k]
          end
        end
      end
      r
    end

    # We could consider `.safe_constantize` to make this a f(n), but we'd have
    # to have a list somewhere else anyways to further restrict allowed classes.
    #
    FILTER_QUERIES = {
      asserted_distribution_query: '::Queries::AssertedDistribution::Filter',
      biological_association_query: '::Queries::BiologicalAssociation::Filter',
      collecting_event_query: '::Queries::CollectingEvent::Filter',
      collection_object_query: '::Queries::CollectionObject::Filter',
      content_query: '::Queries::Content::Filter',
      descriptor_query: '::Queries::Descriptor::Filter',
      extract_query: '::Queries::Extract::Filter',
      image_query: '::Queries::Image::Filter',
      loan_query: '::Queries::Loan::Filter',
      observation_query: '::Queries::Observation::Filter',
      otu_query: '::Queries::Otu::Filter',
      person_query: '::Queries::Person::Filter',
      source_query: '::Queries::Source::Filter',
      taxon_name_query: '::Queries::TaxonName::Filter',
    }.freeze

    #
    # With/out facets
    #
    # To add a corresponding With/Out facet in the UI simply
    # give it a title (must correspond with the param name) in
    #  const WITH_PARAM = [ 'citations' ];
    #

    # @return [Array]
    # @param project_id [Array, Integer]
    attr_accessor :project_id

    # @return [Array]
    # @params object_global_id
    #   Rails global ids.
    #  Locally these look like gid://taxon-works/Otu/1
    # Using a global id is equivalent to 
    # using <model>_id.  I.e. it simply restricts
    # the filter to those matching Model#id.
    #
    # !! If any global id model name does not 
    # match the current filter, then then facet
    # is completely rejected.
    attr_accessor :object_global_id

    # TODO: macro these dynamically

    # @return [Query::AssertedDistributionn::Filter, nil]
    attr_accessor :asserted_distribution_query

    # @return [Query::BiologicalAssociation::Filter, nil]
    attr_accessor :biological_association_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :collection_object_query

    # @return [Query::CollectingEvent::Filter, nil]
    attr_accessor :collecting_event_query

    # @return [Query::Content::Filter, nil]
    attr_accessor :content_query

    # @return [Query::Descriptor::Filter, nil]
    attr_accessor :descriptor_query

    # @return [Query::Image::Filter, nil]
    attr_accessor :image_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :taxon_name_query

    # @return [Query::Otu::Filter, nil]
    attr_accessor :otu_query

    # @return [Query::Extract::Filter, nil]
    attr_accessor :extract_query

    # @return [Query::Observation::Filter, nil]
    attr_accessor :observation_query

    # @return [Query::Loan::Filter, nil]
    attr_accessor :loan_query

    # @return [Query::Person::Filter, nil]
    attr_accessor :person_query

    # @return Boolean
    #   Applies an order on updated.
    attr_accessor :recent

    # @return Hash
    # the parsed/permitted params
    #   that were used to on initialize() only!!
    # !! Using setters directly on query parameters will not alter this variable !!
    # !! This is used strictly during the permission process of ActionController::Parameters !!
    attr_reader :params

    # @return Hash
    def initialize(query_params)

      if query_params.kind_of?(Hash)
        @params = query_params
      elsif query_params.kind_of?(ActionController::Parameters)
        @params = deep_permit(query_params).to_hash.deep_symbolize_keys
      elsif query_params.nil?
        @params = {}
      else
        raise TaxonWorks::Error, "can not initialize filter with #{query_params.class.name}"
      end

      @recent = boolean_param(params, :recent)
      @object_global_id = params[:object_global_id]
      @project_id = params[:project_id] || Current.project_id # !! Always on. 

      set_identifier_params(params)
      set_nested_queries(params)
      set_user_dates(params)
    end

    def object_global_id
      [@object_global_id].flatten.compact
    end

    def project_id
      [@project_id].flatten.compact
    end

    def self.included_annotator_facets
      f = [
        ::Queries::Concerns::Users
      ]

      if referenced_klass.annotates?
        f.push ::Queries::Concerns::Polymorphic if self < ::Queries::Concerns::Polymorphic
      else
        f.push ::Queries::Concerns::Citations if self < ::Queries::Concerns::Citations
        f.push ::Queries::Concerns::DataAttributes if self < ::Queries::Concerns::DataAttributes
        f.push ::Queries::Concerns::Depictions if self < ::Queries::Concerns::Depictions
        f.push ::Queries::Concerns::Identifiers if self < ::Queries::Concerns::Identifiers
        f.push ::Queries::Concerns::Notes if self < ::Queries::Concerns::Notes
        f.push ::Queries::Concerns::Protocols if self < ::Queries::Concerns::Protocols
        f.push ::Queries::Concerns::Tags if self < ::Queries::Concerns::Tags
      end

      f
    end

    # @return Array
    #  merges `[:a, {a: []}]` into [:a]
    def self.params
      a = self::PARAMS.dup
      b = a.pop.keys
      (a + b).uniq
    end

    # @return Array, nil
    #   a [:a, :b, {c: []}] formatted Array
    # to be merged into included params
    def self.annotator_params
      h = nil
      if i = included_annotator_facets
        # Setup with the first
        a = i.shift
        h = a.params

        if !h.last.kind_of?(Hash)
          h << {}
        end

        c = h.last

        # Now do the rest
        i.each do |j|
          p = j.params

          if p.last.kind_of?(Hash)
            c.merge!(p.pop)
          end

          h = p + h
        end
      end
      h
    end

    # This method is a preprocessor that discovers, by finding the nested
    # subqueries, which params should be permitted. It is used to build a
    # permitable profile of parameters.
    #
    # That profile is then used in the actual .permit() call.
    #
    # An alternate solution, first tried, is to permit the params directly
    # during inspection for subquries.  This also would work, however there are
    # some nice benefits to having a profile of the allowed params available as an Array,
    # for example we can use it for API documentation a little easier(?!).
    #
    # In essence what we needed was for ActionController::Parameters to be
    # able to accumulate (remember) all permitted params (not just their actual data)
    # over multiple .permit() calls.  If we had that, then we could do
    # something like params.permitted_params => Array after multiple calls like params.permit(:a),
    # params.permit(:b).
    #
    # @return Hash
    # @params hsh Hash
    #    Uses an *unsafe* hash from an instance of ActionController::Parameters or
    # any parameter set for the query.
    def permitted_params(hsh)
      h = self.class::PARAMS.deep_dup

      if !h.last.kind_of?(Hash)
        h << {}
      end

      c = h.last # a {}

      if n = self.class.annotator_params
        c.merge!(n.pop)
        h = n + h
      end

      b = subquery_vector(hsh)

      parent = self.class

      while !b.empty?
        a = b.shift

        next unless SUBQUERIES[parent.base_name.to_sym].include?( a.to_s.gsub('_query', '').to_sym )

        q = FILTER_QUERIES[a].safe_constantize
        p = q::PARAMS.deep_dup

        if !p.last.kind_of?(Hash)
          p << {}
        end

        if n = q.annotator_params
          p.last.merge!(n.pop)
          p = n + p
        end

        c[a] = p

        c = p.last

        parent = q
      end

      h
    end

    # @params hsh Hash
    # @return [Array of Symbol]
    #   all queries, in nested order
    # Since queries nest linearly we don't need to recursion.
    def subquery_vector(hsh)
      result = []
      while !hsh.keys.select{|k| k =~ /_query/}.empty?
        a = hsh.keys.select{|k| k =~ /_query/}
        result += a
        hsh = hsh[a.first]
      end
      result.map(&:to_sym)
    end

    # @params params ActionController::Parameters
    # @return ActionController::Parameters
    def deep_permit(params)
      p = params.permit( permitted_params(params.to_unsafe_hash))
    end

    # @params params [Hash]
    #   set all nested queries variables, e.g. @otu_filter_query
    # @return True
    def set_nested_queries(params)
      if n = params.select{|k, p| k.to_s =~ /_query/ }
        return nil if n.keys.count != 1 # can't have multiple nested queries inside one level

        query_name = n.first.first

        return nil unless SUBQUERIES[base_name.to_sym].include?( query_name.to_s.gsub('_query', '').to_sym ) # must be registered

        query_params = n.first.last

        q = FILTER_QUERIES[query_name].safe_constantize.new(query_params)

        # assign to @<model>_query
        v = send("#{query_name}=".to_sym, q)
      end

      true
    end

    # @params params [Hash, ActionControllerParameters]
    #   in practice we only pass Hash
    # See CE, Loan filters for use.
    def set_attributes(params)
      self.class::ATTRIBUTES.each do |a|
        send("#{a}=", params[a.to_sym])
      end
    end

    # Returns id= facet, automatically
    # added to all queries.
    # Over-ridden in some base classes.
    def model_id_facet
      m = (base_name + '_id').to_sym
      return nil if send(m).empty?
      table[:id].eq_any(send(m))
    end

    def project_id_facet
      return nil if project_id.empty?
      table[:project_id].eq_any(project_id)
    end

    def object_global_id_facet
      return nil if object_global_id.empty?
      ids = []
      object_global_id.each do |i|
        g = GlobalID.parse(i)
        # If any global_ids do not reference this Class, abort
        return nil unless g.model_class.base_class.name == referenced_klass.name
        ids.push g.model_id
      end

      table[:id].eq_any(ids)
    end

    # params attribute [Symbol]
    #   a facet for use when params include `author`, and `exact_author` pattern combinations
    #   See queries/source/filter.rb for example use
    #   See /spec/lib/queries/source/filter_spec.rb
    #  !! Whitespace (e.g. tabs, newlines) is ignored when exact is used !!!
    def attribute_exact_facet(attribute = nil)
      a = attribute.to_sym
      return nil if send(a).blank?
      if send("exact_#{a}".to_sym)

        # TODO: Think we need to handle ' and '

        v = send(a)
        v.gsub!(/\s+/, ' ')
        v = ::Regexp.escape(v)
        v.gsub!(/\\\s+/, '\s*') # spaces are escaped, but we need to expand them in case we dont' get them caught
        v = '^\s*' + v + '\s*$'

        table[a].matches_regexp(v)
      else
        table[a].matches('%' + send(a).strip.gsub(/\s+/, '%') + '%')
      end
    end

    def annotator_merge_clauses
      a = []

      # !! Interesting `.compact` removes #<ActiveRecord::Relation []>,
      # so patterns that us collect.flatten.compact return empty,
      #  `.present?` fails as well, so verbose loops here
      self.class.included_annotator_facets.each do |c|
        if c.respond_to?(:merge_clauses)
          c.merge_clauses.each do |f|
            if v = send(f)
              a.push v
            end
          end
        end
      end
      a
    end

    def annotator_and_clauses
      a = []
      self.class.included_annotator_facets.each do |c|
        if c.respond_to?(:and_clauses)
          c.and_clauses.each do |f|
            if v = send(f)
              a.push v
            end
          end
        end
      end
      a
    end

    def shared_and_clauses
      [
        project_id_facet,
        model_id_facet,
        object_global_id_facet,
      ]
    end

    # Defined in inheriting classes
    def and_clauses
      []
    end

    # @return [ActiveRecord::Relation, nil]
    def all_and_clauses
      clauses = and_clauses + annotator_and_clauses + shared_and_clauses
      clauses.compact!
      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

    # Defined in inheriting classes
    def merge_clauses
      []
    end

    # @return [Scope, nil]
    def all_merge_clauses
      clauses = merge_clauses + annotator_merge_clauses
      clauses.compact!
      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.merge(b)
      end
      a
    end

    # @param nil_empty [Boolean]
    #   If true then if there are no clauses return nil not .all
    # @return [ActiveRecord::Relation]
    def all(nil_empty = false)
      a = all_and_clauses
      b = all_merge_clauses

      return nil if nil_empty && a.nil? && b.nil?

      q = nil
      if a && b
        q = b.where(a).distinct
      elsif a
        q = referenced_klass.where(a).distinct
      elsif b
        q = b.distinct
      else
        q = referenced_klass.all
      end

      if recent
        q = referenced_klass.from(q.all, table.name).order(updated_at: :desc)
      end

      q
    end

  end
end
