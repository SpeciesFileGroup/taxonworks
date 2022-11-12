module Queries
  module Otu
    class Filter < Queries::Query

    # Changelog
    # `name` now handles one or more of Otu#name
    # `geographic_area_ids` -> `geographic_area_id
    # `otu_ids` -> `otu_id (String or Array)
    # removed `taxon_name_ids`, allowed Array for `taxon_name_id`
    # created Queries::Concerns::Citations  Citation concern and refactor filters referencing citations accordingly

    include Queries::Helpers

    # include Queries::Concerns::Tags
    # include Queries::Concerns::Users
    # include Queries::Concerns::Identifiers

    # include Queries::Concerns::Citations

    # @param name [String, Array]
    # @return Array
    #   literal match against one or more Otu#name
    attr_accessor :name

    attr_accessor :name_exact

    # @param otu_id [Integer, Array]
    # @return Array
    #   one or more Otu ids
    attr_accessor :otu_id

    # @param taxon_name_id [Integer, Array]
    # @return Array
    #   one or more Otu taxon_name_id
    attr_accessor :taxon_name_id

    # @param collecting_event_id [Integer, Array]
    # @return Array
    #   one or more collecting_event_id
    # Finds all OTUs that are the current determination of
    # a CollectionObject that was collecting in these
    # Collecting events.
    # Altered by historical_determinations.
    attr_accessor :collecting_event_id

    # @param historical_determinations [Boolean]
    # @return [Boolean, nil]
    # Where applicable:
    #   true - include only historical determinations (ignores only determinations)
    #   false - include both current and historical 
    #   nil - include only current determinations
    # Impacts all TaxonDetermination referencing queries
    attr_accessor :historical_determinations

    # @param biological_association_id [Integer, Array]
    # @return Array
    #   one or more biological_association_id 
    # Finds all OTUs that are the current determination of
    # a CollectionObject that is in the BiologicalAssociation 
    # or are part of the Biological association itself.
    # Altered by historical_determinations.
    attr_accessor :biological_association_id


    # @param asserted_distribution_id [Integer, Array]
    # @return Array
    #   one or more asserted_distribution_id 
    # Finds all OTUs that are in these asserted distributions
    attr_accessor :asserted_distribution_id

    # @param wkt [String]
    #  A Spatial area in WKT format
    attr_accessor :wkt
       
    # @return [Hash, nil]
    #  in geo_json format (no Feature ...) ?!
    attr_accessor :geo_json

    # -- done to here

    # matching some nomenclature query
    # taxon_name_params

    # matching some set of CollectionObjects
    # collection_object_params
    #   collecting_event_params <- objects

    # matching some set of AssertedDistributions

    # @param geographic_area_id [String, Array]
    # @return [Array]
    attr_accessor :geographic_area_id

    attr_accessor :shape

    # NOT USED!
    # via taxon_determinations (collection_object)
    #
    attr_accessor :selection_objects

    attr_accessor :descendants

    attr_accessor :rank_class

    attr_accessor :author_ids
    attr_accessor :and_or_select

    attr_accessor :biological_associations
    attr_accessor :asserted_distributions
    attr_accessor :exact_author

    # with/out
    attr_accessor :taxon_determinations
    attr_accessor :observations
    attr_accessor :contents
    attr_accessor :depictions

    attr_accessor :author # was verbatim_author_string

    attr_accessor :biological_association_ids
    attr_accessor :taxon_name_classification_ids
    attr_accessor :taxon_name_relationship_ids
    attr_accessor :asserted_distribution_ids

    # @return [Hash]
    #   All params managed in Queries::TaxonName::Filter
    #
    # Return all Otus matching a TaxonName in this query
    attr_accessor :taxon_name_query

    # @return [Hash]
    #   All params managed in Queries::CollectionObject::Filter
    #
    # Return all OTUs matching a CollectionObject in this query
    attr_accessor :collection_object_query

    # @return [Hash]
    #   All params managed in Queries::CollectingEvent::Filter
    #
    # Return all OTUs matching a CollectingEvent in this query, i.e.
    # through Determinations on CollectionObjects in this CollectingEvent
    attr_accessor :collecting_event_query

    # @return [Hash]
    #   All params managed in Queries::AssertedDistribution::Filter
    #
    # Return all OTUs in these AssertedDistributions
    attr_accessor :asserted_distribution_query

    # @return [Hash]
    #   All params managed in Queries::AssertedDistribution::Filter
    #
    # Return all OTUs in these BiologicalAssociation
    attr_accessor :biological_association_query

    # @param [Hash] params
    def initialize(params)
      #  params.reject! { |_k, v| v.blank? }

      @otu_id = params[:otu_id]
      @taxon_name_id = params[:taxon_name_id]

      @name = params[:name]
      @name_exact = boolean_param(params, :name_exact)

      @collecting_event_id = params[:collecting_event_id]
      
      @historical_determinations = boolean_param(params, :historical_determinations)

      @biological_association_id = params[:biological_association_id]
      
      @asserted_distribution_id = params[:asserted_distribution_id]

      @wkt = params[:wkt]

      @geo_json = params[:geo_json]


      # ---

      # TODO: set taxon_name_params
      #  @taxon_name_query = Queries::TaxonName::Filter.new(
      #    params.select{|a,b| taxon_name_params.include?(a.to_s) }
   #  )

   #  # TODO: set collection_object_pqrqms
   #  @collection_object_query = Queries::CollectionObject::Filter.new(
   #    params.select{|a,b| collection_object_params.include?(a.to_s) }
   #  )

   #  # TODO: set collecting event params
   #  @collecting_event_query = Queries::CollectingEvent::Filter.new(
   #    params.select{|a,b| collecting_event_params.include?(a.to_s) }
   #  )

   #  # TODO: set asserted distribution params
   #  @asserted_distribution_query = Queries::AssertedDistribution::Filter.new(
   #    params.select{|a,b| asserted_distribution_params.include?(a.to_s) }
   #  )

   #  # TODO: set biological association params
   #  @biological_association_query = Queries::BiologicalAssociation::Filter.new(
   #    params.select{|a,b| biological_association_params.include?(a.to_s) }
   #  )

      @and_or_select = params[:and_or_select]

      @asserted_distributions = boolean_param(params,:asserted_distributions)
      @biological_associations = boolean_param(params,:biological_associations)
      @contents = boolean_param(params, :contents)
      @depictions = boolean_param(params, :depictions)
      @taxon_determinations = boolean_param(params,:taxon_determinations)
      @citations = params[:citations]
      @observations = boolean_param(params, :observations)

      @geographic_area_id = params[:geographic_area_id]
      @shape = params[:drawn_area_shape]

      @selection_objects = params[:selection_objects] || ['CollectionObject', 'AssertedDistribution']

      @author_ids = params[:author_ids]
      @author = params[:author]
      @exact_author = boolean_param(params, :exact_author)

      @rank_class = params[:rank_class]
      @descendants = params[:descendants]

      @biological_association_ids = params[:biological_association_ids] || []

      @taxon_name_classification_ids = params[:taxon_name_classification_ids] || []
      @taxon_name_relationship_ids = params[:taxon_name_relationship_ids] || []
      @asserted_distribution_ids = params[:asserted_distribution_ids] || []
      @project_id = params[:project_id]

      # TODO: could be incorrect
      params.reject!{ |_k, v| v.nil? || (v == '') }

      # set_tags_params(params)
      # set_user_dates(params)
    end

    def table
      ::Otu.arel_table
    end

    def biological_associations_table
      ::BiologicalAssociation.arel_table
    end

    def name
      [@name].flatten.compact.collect{|n| n.strip}
    end

    def geographic_area_id
      [@geographic_area_id].flatten.compact
    end

    def otu_id
      [@otu_id].flatten.compact
    end

    def taxon_name_id
      [@taxon_name_id].flatten.compact
    end

    def collecting_event_id
      [@collecting_event_id].flatten.compact
    end

    def biological_association_id
      [@biological_association_id].flatten.compact
    end

    def asserted_distribution_id
      [@asserted_distribution_id].flatten.compact
    end

    def otu_id_facet
      return nil if otu_id.empty?
      table[:id].eq_any(otu_id)
    end

    def name_facet
      return nil if name.empty?
      if name_exact
        table[:name].eq_any(name)
      else
        table[:name].matches_any( name.collect{|n| '%' + n.gsub(/\s+/, '%') + '%' } )
      end
    end

    def taxon_name_id_facet
      return nil if taxon_name_id.empty?
      table[:taxon_name_id].eq_any(taxon_name_id)
    end

    # TODO: could be optimized with full join pathway perhaps
    def collecting_event_id_facet
      return nil if collecting_event_id.empty?
      q = ::Queries::CollectionObject::Filter.new(collecting_event_id: collecting_event_id)
      if historical_determinations.nil? 
        ::Otu.joins(:collection_objects).where(collection_objects: q.all, taxon_determinations: {position: 1})
      elsif historical_determinations
        ::Otu.joins(:collection_objects).where(collection_objects: q.all).where.not(taxon_determinations: {position: 1})
      else 
        ::Otu.joins(:collection_objects).where(collection_objects: q.all)
      end
    end

    # TODO: could be optimized with full join pathway perhaps
    def biological_association_id_facet
      return nil if biological_association_id.empty?

      q = ::BiologicalAssociation.where(id: biological_association_id)

      q1 = ::Otu.joins(:biological_associations).where(biological_associations: {id: q, biological_association_subject_type: 'Otu'})
      q2 = ::Otu.joins(:related_biological_associations).where(related_biological_associations: {id:  q, biological_association_object_type: 'Otu'} )
      q3 = ::Otu.joins(collection_objects: [:biological_associations] ).where(biological_associations: {id: q, biological_association_subject_type: 'CollectionObject'})
      q4 = ::Otu.joins(collection_objects: [:related_biological_associations] ).where(related_biological_associations: {id: q, biological_association_object_type: 'CollectionObject'})

      if historical_determinations.nil? 
        q3 = q3.where(taxon_determinations: {position: 1})
        q4 = q4.where(taxon_determinations: {position: 1})
      elsif historical_determinations
        q3 = q3.where.not(taxon_determinations: {position: 1})
        q4 = q4.where.not(taxon_determinations: {position: 1})
      end

      query =  [q1,q2,q3,q4].collect{|s| '(' + s.to_sql + ')'}.join(' UNION ')

      ::Otu.from("(#{query}) as otus")
    end


    # TODO:
    # Unused, proper full join example contrasting by ID
    #   All OTUs in these biological Associations
    #   First determination of OTUs in CollectionObjects
    def matching_biological_association_ids
      return nil if biological_association_ids.empty?
      o = table
      ba = biological_associations_table

      a = o.alias("a_")
      b = o.project(a[Arel.star]).from(a)

      c = ba.alias('b1')
      d = ba.alias('b2')

      b = b.join(c, Arel::Nodes::OuterJoin)
        .on(
          a[:id].eq(c[:biological_association_subject_id])
        .and(c[:biological_association_subject_type].eq('Otu'))
        )

      b = b.join(d, Arel::Nodes::OuterJoin)
        .on(
          a[:id].eq(d[:biological_association_object_id])
        .and(d[:biological_association_object_type].eq('Otu'))
        )

      e = c[:biological_association_subject_id].not_eq(nil)
      f = d[:biological_association_object_id].not_eq(nil)

      g = c[:id].eq_any(biological_association_ids)
      h = d[:id].eq_any(biological_association_ids)

      b = b.where(e.or(f).and(g.or(h)))
      b = b.group(a['id'])
      b = b.as('z2_')

      ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
    end

    def asserted_distribution_id_facet
      return nil if asserted_distribution_id.empty?
      ::Otu.joins(:asserted_distributions).where(asserted_distributions: {id: asserted_distribution_id})
    end

    def wkt_facet
      return nil if wkt.nil?
      c = ::Queries::CollectingEvent::Filter.new(wkt: wkt)
      a = ::Queries::AssertedDistribution::Filter.new(wkt: wkt)

      q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all)
      q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all) 

      ::Otu.from("((#{q1.to_sql}) UNION (#{q1.to_sql})) as otus")
    end

    # Shape is a Hash in GeoJSON format
    def geo_json_facet
      return nil if geo_json.nil?

      c = ::Queries::CollectingEvent::Filter.new(geo_json: geo_json)
      a = ::Queries::AssertedDistribution::Filter.new(geo_json: geo_json)

      q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all)
      q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all) 

      ::Otu.from("((#{q1.to_sql}) UNION (#{q1.to_sql})) as otus")
    end

    # ----

    # Query::TaxonName::Filter integration
    def taxon_name_merge_clauses
      c = []

      # Convert base and clauses to merge clauses
      taxon_name_query.base_merge_clauses.each do |i|
        c.push ::Otu.joins(:taxon_name).merge( i )
      end
      c
    end

    def taxon_name_and_clauses
      c = []
      # Convert base and clauses to merge clauses
      taxon_name_query.base_and_clauses.each do |i|
        c.push ::Otu.joins(:taxon_name).where( i )
      end
      c
    end

    # Query::CollectionObject::Filter integration
    #
    def collection_object_merge_clauses
      c = []

      # Convert base and clauses to merge clauses
      collection_object_query.base_merge_clauses.each do |i|
        c.push ::Otu.joins(:collection_objects).merge( i )
      end
      c
    end

    def collection_object_and_clauses
      c = []
      # Convert base and clauses to merge clauses
      collection_object_query.base_and_clauses.each do |i|
        c.push ::Otu.joins(:collection_objects).where( i )
      end
      c
    end

    # Query::CollectingEvent::Filter integration
    #
    def collecting_event_merge_clauses
      c = []

      # Convert base and clauses to merge clauses
      collecting_event_query.base_merge_clauses.each do |i|
        c.push ::Otu.joins(:collecting_events).merge( i )
      end
      c
    end

    def collecting_event_and_clauses
      c = []
      # Convert base and clauses to merge clauses
      collecting_event_query.base_and_clauses.each do |i|
        c.push ::Otu.joins(:collecting_events).where( i )
      end
      c
    end

    # Query::CollectingEvent::Filter integration
    #
    def asserted_distribution_merge_clauses
      c = []

      # Convert base and clauses to merge clauses
      asserted_distribution_query.base_merge_clauses.each do |i|
        c.push ::Otu.joins(:asserted_distributions).merge( i )
      end
      c
    end

    def asserted_distribution_and_clauses
      c = []
      # Convert base and clauses to merge clauses
      asserted_distribution_query.base_and_clauses.each do |i|
        c.push ::Otu.joins(:asserted_distributions).where( i )
      end
      c
    end

    # @return [Boolean]
    def author_set?
      case author_ids
      when nil
        false
      else
        author_ids.count > 0
      end
    end

    # TODO: Deprecate all
    # @return [Boolean]
    def nomen_set?
      !taxon_name_id.nil?
    end

    # @return [Boolean]
    def verbatim_set?
      !author.blank?
    end

    # @return [Boolean]
    def shape_set?
      !shape.nil?
    end

    # @return [Boolean]
    def with_descendants?
      !descendants.nil?
    end

    # ---

    # @return [Scope]
    # TODO: deprecate
    def result
      return ::Otu.none if applied_scopes.empty?
      a = ::Otu.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end

    # @return [Scope]
    # This could be simplified if the AJAX selector returned a geographic_item_id rather than a geographic_area_id
    #
    # 1. find all geographic_items in area(s)/shape.
    # 2. find all georeferences which are associated with result #1
    # 3. find all collecting_events which are associated with result #2
    # 4. find all collection_objects which are associated with result #3
    # 5. find all asserted_distrubutions which are associated with result #1
    # 6. find all otus which are associated with result #4 plus result #5
    #
    def geographic_area_scope
      target_geographic_item_ids = []

      geographic_area_id.each do |ga_id|
        target_geographic_item_ids.push(
          ::GeographicArea.joins(:geographic_items).find(ga_id).default_geographic_item.id
        )
      end

      gi_sql = ::GeographicItem.contained_by_where_sql(target_geographic_item_ids)

      # TODO: make UNION
      ::Otu.where(id: (::Otu.joins(:asserted_distributions)
        .where(asserted_distributions: {id: ::AssertedDistribution.joins(:geographic_items)
        .where(gi_sql).distinct})) +

      (::Otu.joins(:collection_objects)
        .where(collection_objects: {id: ::CollectionObject.joins(:geographic_items)
        .where(gi_sql).distinct})).distinct)
    end

    # @return [Scope]
    #
    # 1. find all collection_objects which are associated with the shape provided.
    # 2. find all asserted_distrubutions which are associated the shape provided.
    # 3. find all otus which are associated with result #1 plus result #2
    #
    def shape_scope
      ::Otu.where(id: (::Otu.joins(:asserted_distributions)
        .where(asserted_distributions: {id: ::GeographicItem.gather_map_data(
          shape,
          'AssertedDistribution',
          project_id)
        .distinct}) +
      ::Otu.joins(:collection_objects)
        .where(collection_objects: {id: ::GeographicItem.gather_map_data(
          shape,
          'CollectionObject',
          project_id)
        .distinct}))
        .uniq)
    end

    # TODO: adapt to nomeclature scope
    # @return [Scope]
    def nomen_scope
      scope1 = ::Otu.joins(:taxon_name).where(taxon_name_id: taxon_name_id)
      scope = scope1
      if scope1.any?
        scope = ::Otu.self_and_descendants_of(scope1.first.id, rank_class) if with_descendants?
      end
      scope
    end

    # TODO: remove/replace with taxon name filter
    # @return [Scope]
    def verbatim_author_facet
      return nil if author.blank?
      if exact_author
        ::Otu.joins(:taxon_name).where(::TaxonName.arel_table[:cached_author_year].eq(author.strip))
      else
        ::Otu.joins(:taxon_name).where(::TaxonName.arel_table[:cached_author_year].matches('%' + author.strip.gsub(/\s/, '%') + '%'))
      end
    end

    # TODO: move/replace with taxon name filter
    # @return [Scope]
    #   1. find all selected taxon name authors
    #   2. find all taxon_names which are associated with result #1
    #   3. find all otus which are associated with result #2
    def author_scope
      r = ::Role.arel_table

      case and_or_select
      when '_or_', nil

        c = r[:person_id].eq_any(author_ids).and(r[:type].eq('TaxonNameAuthor'))
        ::Otu.joins(taxon_name: [:roles]).where(c.to_sql).distinct

      when '_and_'
        table_alias = 'tna' # alias for 'TaxonNameAuthor'

        o = ::Otu.arel_table
        t = ::TaxonName.arel_table

        b = o.project(o[Arel.star]).from(o)
          .join(t)
          .on(t['id'].eq(o['taxon_name_id']))
          .join(r).on(
            r['role_object_id'].eq(t['id']).and(
              r['type'].eq('TaxonNameAuthor')
            )
          )

        author_ids.each_with_index do |person_id, i|
          x = r.alias("#{table_alias}_#{i}")
          b = b.join(x).on(
            x['role_object_id'].eq(t['id']),
            x['type'].eq('TaxonNameAuthor'),
            x['person_id'].eq(person_id)
          )
        end

        b = b.group(o['id']).having(r['person_id'].count.gteq(author_ids.count))
        b = b.as("z_#{table_alias}")

        # noinspection RubyResolve
        ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end
    end

    # rubocop:enable Metrics/MethodLength

    # @return [Array]
    #   determine which scopes to apply based on parameters provided
    def applied_scopes
      scopes = []
      scopes.push :geographic_area_scope unless geographic_area_id.empty?
      scopes.push :shape_scope if shape_set?
      scopes.push :nomen_scope if nomen_set?
      scopes.push :author_scope if author_set?
      scopes.push :verbatim_scope if verbatim_set?
      scopes
    end

    # TODO: deprecate for all
    # @return [Scope]
    def result
      return ::Otu.none if applied_scopes.empty?
      a = ::Otu.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end

    # TODO: nomenclature filter
    def matching_taxon_name_relationship_ids
      return nil if taxon_name_relationship_ids.empty?
      o = table
      ba = ::TaxonNameRelationship.arel_table

      a = o.alias("a_")
      b = o.project(a[Arel.star]).from(a)

      c = ba.alias('b1')
      d = ba.alias('b2')

      b = b.join(c, Arel::Nodes::OuterJoin)
        .on(
          a[:taxon_name_id].eq(c[:subject_taxon_name_id])
        )

      b = b.join(d, Arel::Nodes::OuterJoin)
        .on(
          a[:id].eq(d[:object_taxon_name_id])
        )

      e = c[:subject_taxon_name_id].not_eq(nil)
      f = d[:object_taxon_name_id].not_eq(nil)

      g = c[:id].eq_any(taxon_name_relationship_ids)
      h = d[:id].eq_any(taxon_name_relationship_ids)

      b = b.where(e.or(f).and(g.or(h)))
      b = b.group(a['id'])
      b = b.as('z1_')

      ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
    end

    # TODO: nomenclature filter
    def matching_taxon_name_classification_ids
      return nil if taxon_name_classification_ids.empty?
      o = table
      tnc = ::TaxonNameClassification.arel_table

      a = o.alias("a_")
      b = o.project(a[Arel.star]).from(a)

      c = tnc.alias('tnc1')

      b = b.join(c, Arel::Nodes::OuterJoin)
        .on(
          a[:taxon_name_id].eq(c[:taxon_name_id])
        )

      e = c[:id].not_eq(nil)
      f = c[:id].eq_any(taxon_name_classification_ids)

      b = b.where(e.and(f))
      b = b.group(a['id'])
      b = b.as('z3_')

      ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
    end

    # TODO asserted distribution filter
    def matching_asserted_distribution_ids
      return nil if asserted_distribution_ids.empty?
      o = table
      ad = ::AssertedDistribution.arel_table

      a = o.alias("a_")
      b = o.project(a[Arel.star]).from(a)

      c = ad.alias('ad1')

      b = b.join(c, Arel::Nodes::OuterJoin)
        .on(
          a[:id].eq(c[:otu_id])
        )

      e = c[:otu_id].not_eq(nil)
      f = c[:id].eq_any(asserted_distribution_ids)

      b = b.where(e.and(f))
      b = b.group(a['id'])
      b = b.as('z4_')

      ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
    end

    # TODO: citations plugin?
    def citations_facet
      return nil if @citations.nil?

      citation_conditions = ::Citation.arel_table[:citation_object_id].eq(::Otu.arel_table[:id]).and(
        ::Citation.arel_table[:citation_object_type].eq('Otu'))

      if @citations == 'without_origin_citation'
        citation_conditions = citation_conditions.and(::Citation.arel_table[:is_original].eq(true))
      end

      ::Otu.where.not(::Citation.where(citation_conditions).arel.exists)
    end

    # TODO: deprecate to biological associtations.
    def biological_associations_facet
      return nil if biological_associations.nil?
      subquery = ::BiologicalAssociation.where(::BiologicalAssociation.arel_table[:biological_association_subject_id].eq(::Otu.arel_table[:id]).and(
        ::BiologicalAssociation.arel_table[:biological_association_subject_type].eq('Otu'))
                                              ).arel.exists
                                              ::Otu.where(biological_associations ? subquery : subquery.not)
    end

    def asserted_distributions_facet
      return nil if asserted_distributions.nil?

      subquery = ::AssertedDistribution.where(::AssertedDistribution.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
      ::Otu.where(asserted_distributions ? subquery : subquery.not)
    end

    def determinations_facet
      return nil if taxon_determinations.nil?

      subquery = ::TaxonDetermination.where(::TaxonDetermination.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
      ::Otu.where(taxon_determinations ? subquery : subquery.not)
    end

    def depictions_facet
      return nil if depictions.nil?
      subquery = ::Depiction.where(::Depiction.arel_table[:depiction_object_id].eq(::Otu.arel_table[:id]).and(
        ::Depiction.arel_table[:depiction_object_type].eq('Otu'))).arel.exists
      ::Otu.where(depictions ? subquery : subquery.not)
    end

    def observations_facet
      return nil if observations.nil?

      subquery = ::ObservationMatrixRow.where(::ObservationMatrixRow.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
      ::Otu.where(observations ? subquery : subquery.not)
    end

    def contents_facet
      return nil if contents.nil?

      subquery = ::Content.where(::Content.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
      ::Otu.where(contents ? subquery : subquery.not)
    end

    # @return [ActiveRecord::Relation, nil]
    def and_clauses
      clauses = [
        otu_id_facet,
        taxon_name_id_facet,
        name_facet,

        # matching_verbatim_author
        # Queries::Annotator.annotator_params(options, ::Citation),
      ].compact

      return nil if clauses.empty?

      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

   # def base_and_clauses
   # end

    def base_merge_clauses
      clauses = []

    # clauses += taxon_name_merge_clauses + taxon_name_and_clauses
    # clauses += collection_object_merge_clauses + collection_object_and_clauses
    # clauses += collecting_event_merge_clauses + collecting_event_and_clauses
    # clauses += asserted_distribution_merge_clauses + asserted_distribution_and_clauses

      clauses += [
        geo_json_facet,
        collecting_event_id_facet,
        biological_association_id_facet,
        asserted_distribution_id_facet,
        wkt_facet,
     #  matching_biological_association_ids,
     #  matching_asserted_distribution_ids,
     #  matching_taxon_name_classification_ids,
     #  matching_taxon_name_relationship_ids,
     #  asserted_distributions_facet,
     #  biological_associations_facet,
     #  citations_facet,
     #  contents_facet,
     #  depictions_facet,
     #  determinations_facet,
     #  observations_facet,
     #  verbatim_author_facet
        # matching_verbatim_author
      ].compact
    end


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
      if a && b
        b.where(a).distinct
      elsif a
        ::Otu.where(a).distinct
      elsif b
        b.distinct
      else
        ::Otu.all
      end
    end

  end
  end
end

