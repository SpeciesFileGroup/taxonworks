# See also ARCHITECTURE.md
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
  # Test coverage is currently in /spec/lib/queries/.
  #
  # !! When adding a new query tests do some linting of parameters, constants etc. Run them early and often !!
  #
  class Query::Filter < Queries::Query

    include Queries::Concerns::Users
    # include Queries::Concerns::Identifiers # Presently in Queries for other use in autocompletes

    #
    # !! SUBQUERIES is cross-referenced in app/javascript/vue/components/radials/filter/links/*.js models.
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
    #
    # !! If you add a `def <model>_query_facet`` to a filter you will get warnings if that
    # !! model is not referencened in this constant.
    #
    SUBQUERIES = {
      asserted_distribution: [:source, :otu, :biological_association, :taxon_name, :dwc_occurrence],
      biological_association: [:source, :collecting_event, :otu, :collection_object, :field_occurrence, :taxon_name, :asserted_distribution], # :field_occurrence
      biological_associations_graph: [:biological_association, :source],
      collecting_event: [:source, :collection_object, :field_occurrence, :biological_association, :otu, :image, :taxon_name, :dwc_occurrence],
      collection_object: [:source, :loan, :otu, :taxon_name, :collecting_event, :biological_association, :extract, :image, :observation, :dwc_occurrence],
      content: [:source, :otu, :taxon_name, :image],
      conveyance: [:sound],
      controlled_vocabulary_term: [:data_attribute],
      data_attribute: [:collection_object, :collecting_event, :field_occurrence, :taxon_name, :otu],
      dwc_occurrence: [:asserted_distribution, :collection_object, :collecting_event, :field_occurrence],
      depiction: [:image],
      descriptor: [:source, :observation, :otu],
      extract: [:source, :otu, :collection_object, :observation],
      field_occurrence: [:collecting_event, :otu, :biological_association, :dwc_occurrence, :image, :observation, :taxon_name], # [:source, :otu, :collecting_event, :biological_association, :observation, :taxon_name, :extract],
      image: [:content, :collection_object, :collecting_event, :field_occurrence, :otu, :observation, :source, :taxon_name ],
      loan: [:collection_object, :otu],
      observation: [:collection_object, :descriptor, :extract, :field_occurrence, :image, :otu, :sound, :source, :taxon_name],
      otu: [:asserted_distribution, :biological_association, :collection_object, :dwc_occurrence, :field_occurrence, :collecting_event, :content, :descriptor, :extract, :image, :loan, :observation, :source, :taxon_name ],
      person: [],
      source: [:asserted_distribution,  :biological_association, :collecting_event, :collection_object, :content, :descriptor, :extract, :image, :observation, :otu, :taxon_name],
      sound: [:observation],
      taxon_name: [:asserted_distribution, :biological_association, :collection_object, :collecting_event, :image, :otu, :source, :taxon_name_relationship],
      taxon_name_relationship: [:taxon_name],
    }.freeze

    def self.query_name
      base_name + '_query'
    end

    delegate :query_name, to: :class

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
      biological_associations_graph_query: '::Queries::BiologicalAssociationsGraph::Filter',
      collecting_event_query: '::Queries::CollectingEvent::Filter',
      collection_object_query: '::Queries::CollectionObject::Filter',
      content_query: '::Queries::Content::Filter',
      controlled_vocabulary_term_query: '::Queries::ControlledVocabularyTerm::Filter',
      conveyance_query: '::Queries::Conveyance::Filter',
      data_attribute_query: '::Queries::DataAttribute::Filter',
      depiction_query: '::Queries::Depiction::Filter',
      descriptor_query: '::Queries::Descriptor::Filter',
      document_query: '::Queries::Document::Filter',
      dwc_occurrence_query: '::Queries::DwcOccurrence::Filter',
      extract_query: '::Queries::Extract::Filter',
      field_occurrence_query: '::Queries::FieldOccurrence::Filter',
      image_query: '::Queries::Image::Filter',
      loan_query: '::Queries::Loan::Filter',
      observation_query: '::Queries::Observation::Filter',
      otu_query: '::Queries::Otu::Filter',
      person_query: '::Queries::Person::Filter',
      sound_query: '::Queries::Sound::Filter',
      source_query: '::Queries::Source::Filter',
      taxon_name_query: '::Queries::TaxonName::Filter',
      taxon_name_relationship_query: '::Queries::TaxonNameRelationship::Filter',
    }.freeze

    # @return [Array]
    # @param project_id [Array, Integer, false]
    #  !! when passed false then Current.project_id is not applied, i.e. the result will be []
    #  !! use the false pattern only for internal calls (e.g. rewriting
    attr_accessor :project_id

    # Apply pagination within Filter scope
    #   true - apply per and page
    #   false, nil - ignored
    attr_accessor :paginate

    # @return Integer, nil
    #   required if paginate == true
    attr_accessor :page

    # @return Integer, nil
    #   paginate must equal true
    #   page must be !nil?
    attr_accessor :per

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

    # @return [Query::BiologicalAssociationsGraph::Filter, nil]
    attr_accessor :biological_associations_graph_query

    # @return [Query::ControlledVocabularyTerm::Filter, nil]
    attr_accessor :controlled_vocabulary_term_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :collection_object_query

    # @return [Query::CollectingEvent::Filter, nil]
    attr_accessor :collecting_event_query

    # @return [Query::Content::Filter, nil]
    attr_accessor :content_query

    # @return [Query::Conveyance::Filter, nil]
    attr_accessor :conveyance_query

    # @return [Query::DataAttribute::Filter, nil]
    attr_accessor :data_attribute_query

    # @return [Query::Descriptor::Filter, nil]
    attr_accessor :descriptor_query

    # @return [Query::Depiction::Filter, nil]
    attr_accessor :depiction_query

    # @return [Query::Document::Filter, nil]
    attr_accessor :document_query

    # @return [Query::DwcOccurrence::Filter, nil]
    attr_accessor :dwc_occurrence_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :field_occurrence_query

    # @return [Query::Image::Filter, nil]
    attr_accessor :image_query

    # @return [Query::TaxonName::Filter, nil]
    attr_accessor :taxon_name_query

    # @return [Query::TaxonNameRelationship::Filter, nil]
    attr_accessor :taxon_name_relationship_query

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

    # @return [Query::Sound::Filter, nil]
    attr_accessor :sound_query

    # @return Boolean
    #   Applies an order on updated.
    attr_accessor :recent

    # @return symbol :created_at, :updated_at
    #   defaults to :updated_at if blank
    attr_accessor :recent_target

    # @return Boolean
    #   When true api_except_params is applied and
    #   other restrictions are placed:
    #     - :venn param is ignored
    #     - is_public=true is applied
    attr_accessor :api

    # @return String
    #   A JSON full URL containing the base string for a query
    attr_accessor :venn

    # @return Symbol one of :a, :ab, :b
    #    :a :ab  :b
    #  ( A ( B ) C )
    attr_accessor :venn_mode

    # @return Boolean
    # When true, all paging parameters will be removed from the B query and it
    # will return its full result set for venn processing.
    # When false, the B venn query will use only the single page indicated by
    # whatever paging parameters are set on the query.
    attr_accessor :venn_ignore_pagination

    # @return symbol
    #   must match a existing parameter name (used to check if values provided)
    #
    # @param order_by [String, Symbol]
    #   the kind of sort to apply.
    #
    # Supported values:
    #   * `match_identifiers` - sort by the order of the identifiers in provided
    #
    # !! Does not sub-sort
    #
    attr_accessor :order_by

    # @return Hash
    #  the parsed/permitted params
    #   that were used to on initialize() only!!
    # !! Using setters directly on query parameters will not alter this variable !!
    # !! This is used strictly during the permission process of ActionController::Parameters !!
    attr_reader :params

    # @return Boolean
    # If true then *_facet methods need only return
    # scope.none to indicate that the facet is active
    # given the current parameters. Facet return scopes
    # are never actually queried in this case.
    # If you're a facet that does work to create your scope
    # then you should check this attribute and *not* do
    # that work when it's true. Otherwise you can safely
    # ignore this.
    attr_accessor :roll_call

    # @params query_params [ActionController::Parameters]
    def initialize(query_params)

      # Reference to query_params, i.e. always permitted
      @api = boolean_param(query_params, :api)

      @recent = boolean_param(query_params, :recent)
      @recent_target = query_params[:recent_target]

      @object_global_id = query_params[:object_global_id]

      @venn = query_params[:venn]
      @venn_mode = query_params[:venn_mode]
      @venn_ignore_pagination = boolean_param(query_params, :venn_ignore_pagination)

      # !! This is the *only* place Current.project_id should be seen !! It's still not the best
      # way to implement this, but we use it to optimize the scope of sub/nested-queries efficiently.
      # Ideally we'd have a global class param that stores this that all Filters would have access to,
      # rather than an instance variable
      @project_id = case
                    when query_params[:project_id] == false # !! Only internal should pass this, therefor no type conversions
                      nil
                    when query_params[:project_id].blank?
                      Current.project_id
                    else
                      query_params[:project_id]
                    end

      @paginate = boolean_param(query_params, :paginate)
      @per = query_params[:per]
      @page = query_params[:page]

      @order_by = query_params[:order_by]

      @roll_call = false

      # After this point, if you started with ActionController::Parameters,
      # then all values have been explicitly permitted.
      if query_params.kind_of?(Hash)
        @params = query_params
      elsif query_params.kind_of?(ActionController::Parameters)
        @params = deep_permit(query_params).to_hash.deep_symbolize_keys
      elsif query_params.nil?
        @params = {}
      else
        raise TaxonWorks::Error, "can not initialize filter with #{query_params.class.name}"
      end
      set_identifier_params(params)
      set_nested_queries(params)
      set_user_dates(params)
    end

    def order_by
      return nil if @order_by.blank?
      @order_by.to_sym
    end

    def object_global_id
      [@object_global_id].flatten.compact
    end

    def project_id
      [@project_id].flatten.compact
    end

    def recent_target
      return :updated_at if @recent_target.blank?
      r = @recent_target.to_s.downcase.to_sym
      return :updated_at unless [:updated_at, :created_at].include?(r)
      r
    end

    def venn_mode
      v = @venn_mode.to_s.downcase.to_sym
      if [:a, :ab, :b].include?(v)
        v
      else
        nil
      end
    end

    def process_url_into_params(url)
      Rack::Utils.parse_nested_query(url)
    end

    # @params [Parameters]
    # @return [Filter, nil]
    #    the class of filter that is referenced at the base of this parameter set
    def self.base_filter(params)
      if s = base_query_name(params)
        t = s.gsub('_query', '').to_sym

        if SUBQUERIES.include?(t)
          k = t.to_s.camelcase
          return "Queries::#{k}::Filter".constantize
        else
          return nil
        end
      else
        nil
      end
    end

    # An instiatied filter, with params set, for params with patterns like `otu_query={}`
    def self.instantiated_base_filter(params)
      if s = base_filter(params)
        s.new(params[base_query_name(params)])
      else
        nil
      end
    end

    def self.base_query_name(params)
      params.keys.select{|s| s =~ /\A.+_query\z/}.first
    end

    # @return the params use to instantiate the full
    # base_query, as params, like `{otu_query: {}}`
    # This sanitizes params.
    def self.base_query_to_h(params)
      return { base_query_name(params) => instantiated_base_filter(params).params }
    end

    def self.included_annotator_facets
      f = [
        ::Queries::Concerns::Users
      ]

      if referenced_klass.annotates?
        f.push ::Queries::Concerns::Polymorphic if self < ::Queries::Concerns::Polymorphic
      else
        # TODO There is room for an AlternateValue concern here
        f.push ::Queries::Concerns::Attributes if self < ::Queries::Concerns::Attributes
        f.push ::Queries::Concerns::Citations if self < ::Queries::Concerns::Citations
        f.push ::Queries::Concerns::Confidences if self < ::Queries::Concerns::Confidences
        f.push ::Queries::Concerns::Containable if self < ::Queries::Concerns::Containable
        f.push ::Queries::Concerns::Conveyances if self < ::Queries::Concerns::Conveyances
        f.push ::Queries::Concerns::DataAttributes if self < ::Queries::Concerns::DataAttributes
        f.push ::Queries::Concerns::DateRanges if self < ::Queries::Concerns::DateRanges
        f.push ::Queries::Concerns::Depictions if self < ::Queries::Concerns::Depictions
        f.push ::Queries::Concerns::Identifiers if self < ::Queries::Concerns::Identifiers
        f.push ::Queries::Concerns::Notes if self < ::Queries::Concerns::Notes
        f.push ::Queries::Concerns::Protocols if self < ::Queries::Concerns::Protocols
        f.push ::Queries::Concerns::Tags if self < ::Queries::Concerns::Tags
        f.push ::Queries::Concerns::Verifiers if self < ::Queries::Concerns::Verifiers
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

    # Any params set here, and in corresponding subclasses will not
    # be permitted when api: true is present
    def self.api_except_params
      [:venn, :venn_mode]
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

    def self.api_excluded_params
      [
        # if there are things like created_by_id that we deem universally out they go here
      ] + api_except_params
    end

    # This method is a preprocessor that discovers, by finding the nested
    # subqueries, which params should be permitted. It is used to build a
    # permitable profile of parameters.
    #
    # That profile is then used in the actual .permit() call.
    #
    # An alternate solution, first tried, is to permit the params directly
    # during inspection for subqueries. This also would work, however there are
    # some nice benefits to having a profile of the allowed params available as an Array,
    # for example we can use it for API documentation a little easier(?!).
    #
    # In essence what we needed was for ActionController::Parameters to be
    # able to accumulate (remember) all permitted params (not just their actual data)
    # over multiple .permit() calls.  If we had that, then we could do
    # something like params.permitted_params => Array after multiple calls like params.permit(:a),
    # params.permit(:b).
    #
    # @return Array like [:a,:b, :c, {d: []}]
    # @params hsh Hash
    #    Uses an *unsafe* hash from an instance of ActionController::Parameters or
    # any parameter set for the query.
    def permitted_params(hsh)
      h = self.class::PARAMS.deep_dup
      h.unshift(:per)
      h.unshift(:page)
      h.unshift(:paginate)

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

        p.unshift(:per)
        p.unshift(:page)
        p.unshift(:paginate)

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

      if api
        self.class.api_excluded_params.each do |a|
          h.delete_if{|k,v| a == k}
          h.last.delete_if{|k,v| a == k }
        end
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
    # TODO: when a nesting problem is found we need to flag the query as invalid
    def set_nested_queries(params)

      if n = params.select{|k, p| k.to_s =~ /_query/ }
        return nil if n.keys.count != 1 # !!! can't have multiple nested queries inside one level !!! This lets us eliminate infinite loops at the cost of expressiveness?!

        query_name = n.first.first

        return nil unless SUBQUERIES[base_name.to_sym].include?( query_name.to_s.gsub('_query', '').to_sym ) # must be registered

        query_params = n.first.last

        q = FILTER_QUERIES[query_name].safe_constantize.new(query_params)

        # assign to @<model>_query
        send("#{query_name}=".to_sym, q)
      end

      true
    end

    # Returns id= facet, automatically
    # added to all queries.
    # Over-ridden in some base classes.
    def model_id_facet
      m = (base_name + '_id').to_sym
      return nil if send(m).empty?
      table[:id].in(send(m))
    end

    def project_id_facet
      return nil if project_id.empty?
      table[:project_id].in(project_id)
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

      table[:id].in(ids)
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
          next if c.name == 'Queries::Concerns::Identifiers' && no_identifier_clauses
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
      clauses = target_and_clauses
      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

    def target_and_clauses
      [and_clauses + annotator_and_clauses + shared_and_clauses].flatten.compact
    end

    # Defined in inheriting classes
    def merge_clauses
      []
    end

    # @return [Scope, nil]
    #
    # Of interest, the previous native `merge()` (and `and()``) make things complicated:
    #
    # For example a.merge(b) != b.merge(a) in some cases. This is because certain clauses
    # are tossed without warning (notably `.from()`). See:
    # - https://github.com/rails/rails/issues/33501#issuecomment-722700538
    #  - https://www.bigbinary.com/blog/rails-7-adds-active-record-relation-structurally-compatible
    #
    # We presently use SQL with INTERSECTION to combine facets.
    #
    def all_merge_clauses
      clauses = merge_clauses + annotator_merge_clauses
      clauses.compact!

      return nil if clauses.empty?

      # TODO: consider whether to implement this.
      # It should be safe, except, possibly for aggregate based queries
      # that include custom attributes, would these get cleared.
      # We could requier that at this level they are wrapped in a From etc.
      # a = clauses.collect{|q| q.unscope(:select).select(:id) }

      referenced_klass_intersection(clauses)
    end

    def apply_venn(query)
      Queries.venn(query, venn_query.all, venn_mode)
    end

    def venn_query
      u = ::Addressable::URI.parse(venn).query
      # Brackets may be multi-encoded
      t = nil
      i = 0
      max = 10
      while t != u && i < max
        t = u
        u = Addressable::URI.unencode(t)
        i += 1
      end

      p = ::Rack::Utils.parse_nested_query(u) # nested supports brackets
      p = p.except('per', 'page', 'paginate') if venn_ignore_pagination

      a = ActionController::Parameters.new(p)

      self.class.new(a)
    end

    # @return Boolean
    #   true - the only param pasted is `project_id` !! Note that this is the default for all queries, it is set on initialize
    #   false - there are no params at ALL or at least one that is not `project_id`, and project_id != false
    def only_project?
      @roll_call = true
      a = (project_id_facet &&
        target_and_clauses.size == 1 &&
        all_merge_clauses.nil?) ? true : false
      @roll_call = false

      a
    end

    # @param nil_empty [Boolean]
    #   If true then if there are no clauses return nil not .all
    # @return [ActiveRecord::Relation]
    #
    # See /lib/queries/ARCHITECTURE.md for additional explanation.
    #
    # TODO: consider "true" for default, changing to false on controller
    # Filter  calls
    def all(nil_empty = false)

      # TODO: should turn off/on project_id here on nil empty?

      a = all_and_clauses
      b = all_merge_clauses

      # TODO: do not consider project_id alone a parameter on nil_empty

      # Limited use within the UI because project_id is set
      return nil if nil_empty && a.nil? && b.nil?

      # !! Do not apply `.distinct here`

      q = nil
      if a && b
        q = b.where(a)
      elsif a
        q = referenced_klass.where(a)
      elsif b
        q = b
      else
        q = referenced_klass.all
      end

      if venn_mode && venn && !api
        q = apply_venn(q)
      end

      # TODO: collides with recent, and needs isolation/generic application
      # probably through native .order() use.
      # Order in general likely belongs outside the scope of filters, but
      # see this param use, where we depend on the incoming values
      #
      # See spec/lib/queries/otu/filter_spec.rb for tests

      # See lib/queries/concerns/identifiers.rb
      if order_by
        q = match_identifier_order_by(q)
      end

      if recent
        q = referenced_klass.from(q.all, table.name).order(recent_target => :desc)
      end

      if api
        if referenced_klass.column_names.include?('is_public')
          q = q.where(is_public: [nil, true])
        end
      end

      if paginate
        if order_by
          q = q.page(page).per(per)
        else
          q = q.order(:id).page(page).per(per)
        end
      end

      # TODO: canonically address whether or not to use `.distinct` at this point, we should be able to, however
      # some incoming queries may have joins/group/etc. alone?! I.e. why can't we?

      q
    end

  end
end
