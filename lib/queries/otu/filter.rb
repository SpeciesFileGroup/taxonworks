module Queries

  class Otu::Filter < Queries::Query

    # Query variables
    attr_accessor :query_geographic_area_ids, :query_shape
    attr_accessor :query_nomen_id, :query_descendants, :query_rank_class
    attr_accessor :query_author_ids, :query_and_or_select
    attr_accessor :query_verbatim_author_string

    # def a=(value)
    #   @a = value
    # end
    #
    # def a
    #   @a
    # end
    #
    def initialize(params)
      params.reject! { |_k, v| v.blank? }

      @query_params                 = params
      @query_geographic_area_ids    = params[:geographic_area_ids]
      @query_shape                  = params[:drawn_area_shape]
      @query_author_ids             = params[:author_ids]
      @query_verbatim_author_string = params[:verbatim_author_string]
      @query_and_or_select          = params[:and_or_select]
      @query_nomen_id               = params[:nomen_id]
      @query_rank_class             = params[:rank_class]
      @query_descendants            = params[:descendants]
    end

    def area_set?
      !query_geographic_area_ids.nil?
    end

    def author_set?
      case query_author_ids
        when nil
          false
        else
          query_author_ids.count > 0
      end
    end

    def nomen_set?
      !query_nomen_id.nil?
    end

    def verbatim_set?
      !query_verbatim_author_string.blank?
    end

    def shape_set?
      !query_shape.nil?
    end

    def with_descendants?
      !query_descendants.nil?
    end

=begin
      1. find all geographic_items in area(s)/shape
      2. find all georeferences which are associated with result #1
      3. find all collecting_events which are associated with result #2
      4. find all collection_objects which are associated with result #3
      5. find all otus which are associated with result #4
=end
    # @return [Scope]
    # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
    def geographic_area_scope
      target_geographic_item_ids = []

      query_geographic_area_ids.each do |ga_id|
        target_geographic_item_ids.push(
          GeographicArea.joins(:geographic_items).find(ga_id).default_geographic_item.id
        )
      end
      r42i = CollectionObject.joins(:geographic_items)
               .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
               .distinct
      ::Otu.joins(:collection_objects).where(collection_objects: {id: r42i})
    end

    # @return [Scope]
    def shape_scope
      r42i = GeographicItem.gather_map_data(query_shape, 'CollectionObject').distinct
      ::Otu.joins(:collection_objects).where(collection_objects: {id: r42i})
    end

    # @return [Scope]
    def nomen_scope
      scope1 = ::Otu.joins(:taxon_name).where(taxon_name_id: query_nomen_id)
      scope  = scope1
      if scope1.any?
        scope = ::Otu.self_and_descendants_of(scope1.first.id, query_rank_class) if with_descendants?
      end
      scope
    end

    # @return [Scope]
    def verbatim_scope
      ::Otu.joins(:taxon_name).where('taxon_names.cached_author_year ILIKE ?', "%#{query_verbatim_author_string}%")
    end

=begin
      1. find all selected taxon name authors
      2. find all taxon_names which are associated with result #1
      3. find all otus which are associated with result #2
=end
    # @return [Scope]
    def author_scope
      case query_and_or_select
        when '_or_', nil

          p = ::Person.arel_table

          c = p[:id].eq(query_author_ids.shift)
          query_author_ids.each do |i|
            c = c.or(p[:id].eq(i))
          end

          ::Otu.joins(taxon_name: [roles: [:person]]).where(roles: {type: 'TaxonNameAuthor'}).where(c.to_sql).distinct

        when '_and_'
          table_alias = 'tna' # alias for 'TaxonNameAuthor'

          o = ::Otu.arel_table
          t = ::TaxonName.arel_table
          r = ::Role.arel_table

          b = o.project(o[Arel.star]).from(o)
                .join(t)
                .on(t['id'].eq(o['taxon_name_id']))
                .join(r).on(
            r['role_object_id'].eq(t['id']).and(
              r['type'].eq('TaxonNameAuthor')
            )
          )

          query_author_ids.each_with_index do |person_id, i|
            x = r.alias("#{table_alias}_#{i}")
            b = b.join(x).on(
              x['role_object_id'].eq(t['id']),
              x['type'].eq('TaxonNameAuthor'),
              x['person_id'].eq(person_id)
            )
          end

          b = b.group(o['id']).having(r['person_id'].count.gteq(query_author_ids.count))
          b = b.as("z_#{table_alias}")

          # noinspection RubyResolve
          ::Otu.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end
    end

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
  end
end
