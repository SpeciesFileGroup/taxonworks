module Queries

  # TODO: Unify all and filter
  class Otu::Filter < Queries::Query

    # Query variables
    attr_accessor :geographic_area_ids, :shape
    attr_accessor :selection_objects
    attr_accessor :descendants, :rank_class
    attr_accessor :author_ids, :and_or_select
    attr_accessor :biological_associations
    attr_accessor :asserted_distributions
    attr_accessor :exact_author
    
    attr_accessor :contents
    attr_accessor :depictions

    attr_accessor :taxon_determinations
    attr_accessor :observations

    attr_accessor :author # was verbatim_author_string
    attr_accessor :taxon_name_id, :taxon_name_ids, :otu_id, :otu_ids,
      :biological_association_ids, :taxon_name_classification_ids, :taxon_name_relationship_ids, :asserted_distribution_ids

    attr_accessor :name

    # @param [Hash] params
    def initialize(params)
      params.reject! { |_k, v| v.blank? }
      @and_or_select = params[:and_or_select]

      @asserted_distributions = (params[:asserted_distributions]&.downcase == 'true' ? true : false) if !params[:asserted_distributions].nil?
      @biological_associations = (params[:biological_associations]&.downcase == 'true' ? true : false) if !params[:biological_associations].nil?
      @contents = (params[:contents]&.downcase == 'true' ? true : false) if !params[:contents].nil?
      @depictions = (params[:depictions]&.downcase == 'true' ? true : false) if !params[:depictions].nil?
      @taxon_determinations = (params[:taxon_determinations]&.downcase == 'true' ? true : false) if !params[:taxon_determinations].nil?
      @citations = params[:citations]
      @observations = (params[:observations]&.downcase == 'true' ? true : false) if !params[:observations].nil?

      @geographic_area_ids = params[:geographic_area_ids]
      @shape = params[:drawn_area_shape]
      @selection_objects = params[:selection_objects] || ['CollectionObject', 'AssertedDistribution']
      @author_ids = params[:author_ids]
      @author = params[:author]
      @exact_author = (params[:exact_author]&.downcase == 'true' ? true : false) if !params[:exact_author].nil?

      @rank_class = params[:rank_class]
      @descendants = params[:descendants]

      @name = params[:name]

      @taxon_name_id = params[:taxon_name_id]
      @taxon_name_ids = params[:taxon_name_ids] || []
      @otu_id = params[:otu_id]
      @otu_ids = params[:otu_ids] || []

      @biological_association_ids = params[:biological_association_ids] || []

      @taxon_name_classification_ids = params[:taxon_name_classification_ids] || []
      @taxon_name_relationship_ids = params[:taxon_name_relationship_ids] || []
      @asserted_distribution_ids = params[:asserted_distribution_ids] || []
      @project_id = params[:project_id]
    end

    def table
      ::Otu.arel_table
    end

    def biological_associations_table
      ::BiologicalAssociation.arel_table
    end

    def matching_otu_ids
      a = ids_for_otu
      a.empty? ? nil : table[:id].eq_any(a)
    end

    def matching_name
      a = name
      a.blank? ? nil : table[:name].eq(a)
    end

    # @return [Array]
    #   of otu_id
    def ids_for_otu
      ([otu_id] + otu_ids).compact.uniq
    end

    def matching_taxon_name_ids
      a = ids_for_taxon_name
      a.empty? ? nil : table[:taxon_name_id].eq_any(a)
    end

    # @return [Array]
    #  of taxon_name.id
    def ids_for_taxon_name
      ([taxon_name_id] + taxon_name_ids).compact.uniq
    end

    # @return [Boolean]
    def area_set?
      !geographic_area_ids.nil?
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

      geographic_area_ids.each do |ga_id|
        target_geographic_item_ids.push(
          ::GeographicArea.joins(:geographic_items).find(ga_id).default_geographic_item.id
        )
      end

      gi_sql = ::GeographicItem.contained_by_where_sql(target_geographic_item_ids)

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

    # @return [Scope]
    def nomen_scope
      scope1 = ::Otu.joins(:taxon_name).where(taxon_name_id: taxon_name_id)
      scope = scope1
      if scope1.any?
        scope = ::Otu.self_and_descendants_of(scope1.first.id, rank_class) if with_descendants?
      end
      scope
    end

    # @return [Scope]
    def verbatim_author_facet
      return nil if author.blank?
      if exact_author
        ::Otu.joins(:taxon_name).where(::TaxonName.arel_table[:cached_author_year].eq(author.strip))
      else 
        ::Otu.joins(:taxon_name).where(::TaxonName.arel_table[:cached_author_year].matches('%' + author.strip.gsub(/\s/, '%') + '%'))
      end
    end

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
      scopes.push :geographic_area_scope if area_set?
      scopes.push :shape_scope if shape_set?
      scopes.push :nomen_scope if nomen_set?
      scopes.push :author_scope if author_set?
      scopes.push :verbatim_scope if verbatim_set?
      scopes
    end

    # @return [Scope]
    def result
      return ::Otu.none if applied_scopes.empty?
      a = ::Otu.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end

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

    def citations_facet 
      return nil if citations.nil?

      citation_conditions = ::Citation.arel_table[:citation_object_id].eq(::Otu.arel_table[:id]).and(
        ::Citation.arel_table[:citation_object_type].eq('Otu'))

      if citations == 'without_origin_citation'
        citation_conditions = citation_conditions.and(::Citation.arel_table[:is_original].eq(true))
      end

      ::Otu.where.not(::Citation.where(citation_conditions).arel.exists)
    end

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
        matching_taxon_name_ids,
        matching_otu_ids,
        matching_name,

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

    def merge_clauses
      clauses = [
        matching_biological_association_ids,
        matching_asserted_distribution_ids,
        matching_taxon_name_classification_ids,
        matching_taxon_name_relationship_ids,
        asserted_distributions_facet,
        biological_associations_facet,
        citations_facet,
        contents_facet,
        depictions_facet,
        determinations_facet,
        observations_facet,
        verbatim_author_facet

        # matching_verbatim_author
      ].compact

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
