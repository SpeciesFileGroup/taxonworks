module Queries

  class OtuFilterQuery < Queries::Query

    # Query variables
    attr_accessor :query_geographic_area_ids, :query_shape
    attr_accessor :query_nomen_id, :query_descendants
    attr_accessor :query_author_ids, :query_authors_select

    def initialize(params)
      params.reject! { |k, v| v.blank? }

      @query_geographic_area_ids = params[:geographic_area_ids]
      @query_shape               = params[:drawn_area_shape]
      @query_author_ids          = params[:author_ids] #TODO remove array container when form returns array of IDs
      @query_authors_select      = 'or'
      @query_nomen_id            = params[:nomen_id]
      @query_descendants         = params[:descendants]

    end

    def area_set?
      !query_geographic_area_ids.nil?
    end

    def author_set?
      !query_author_ids.nil?
    end

    def nomen_set?
      !query_nomen_id.nil?
    end

    def shape_set?
      !query_shape.nil?
    end

    def with_descendants?
      query_descendants == 'on'
    end

    # All scopes might end up in Otu directly

    # @return [Scope]
    # def otu_scope
    #   # Challenge: Refactor to use a join pattern instead of SELECT IN
    #   innerscope = with_descendants? ? Otu.self_and_descendants_of(query_nomen_id) : Otu.where(id: query_nomen_id)
    #   # Otu.where(id: innerscope)
    #   innerscope
    # end

=begin
      1. find all geographic_items in area(s)/shape
      2. find all georeferences which are associated with result #1
      3. find all collecting_events which are associated with result #2
      4. find all collection_objects which are associated with result #3
      5. find all otus which are associated with result #4
=end
    # @return [Scope]
    def geographic_area_scope
      # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
      target_geographic_item_ids = []
      query_geographic_area_ids.each do |gaid|
        target_geographic_item_ids.push(GeographicArea.joins(:geographic_items).find(gaid).default_geographic_item.id)
      end
      # r4 = CollectionObject.joins(:geographic_items)
      #        .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
      r42i = CollectionObject.joins(:geographic_items)
               .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
               .distinct
               .pluck(:id)
      # get the Otus associated with r4
      # r5i = r4.map(&:otus).flatten.pluck(:id).uniq
      # r5o = Otu.where(id: r5i)
      r5o2 = Otu.joins(:collection_objects).where('biological_collection_object_id in (?)', r42i)
      # r5o
      r5o2
    end

    # @return [Scope]
    def shape_scope
      # r4   = GeographicItem.gather_map_data(query_shape, 'CollectionObject')
      r42i = GeographicItem.gather_map_data(query_shape, 'CollectionObject')
               .distinct
               .pluck(:id)
      # get the Otus associated with r4
      # r5i = r4.map(&:otus).flatten.pluck(:id).uniq
      # r5o = Otu.where(id: r5i)
      r5o2 = Otu.joins(:collection_objects).where('biological_collection_object_id in (?)', r42i)
      # r5o
      r5o2
    end

    # @return [Scope]     #TODO accomodate multiple OTUs pre taxon name
    def nomen_scope
      a = Otu.joins(:taxon_name).where(taxon_name_id: query_nomen_id)
      if with_descendants?
        b = Otu.none
        a.each { |o|
          b += Otu.self_and_descendants_of(o.id)
        }
        b
      else
        a
      end
    end

=begin
      1. find all selected taxon name authors
      2. find all taxon_names which are associated with result #1
      3. find all otus which are associated with result #2
=end
    # @return [Scope]
    def author_scope
      Otu.joins(:taxon_name).where('taxon_names.id IN (SELECT "taxon_names"."id" FROM "taxon_names" INNER JOIN "roles" ON "taxon_names"."id" = "roles"."role_object_id" WHERE "roles"."type" IN (\'TaxonNameAuthor\') AND "roles"."person_id" IN (?) AND "roles"."role_object_type" = \'TaxonName\' )', query_author_ids)
    end

    # @return [Array]
    #   determine which scopes to apply based on parameters provided
    def applied_scopes
      scopes = []
      scopes.push :geographic_area_scope if area_set?
      scopes.push :shape_scope if shape_set?
      scopes.push :nomen_scope if nomen_set?
      scopes.push :author_scope if author_set?
      scopes
    end

    # @return [Scope]
    def result
      return Otu.none if applied_scopes.empty?
      a = Otu.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end
  end
end
