module Queries
  module CollectionObject

    # !! does not inherit from base query
    class Filter 
      # Boolean (TODO: reconcile with other use) 
      attr_accessor :recent

      attr_accessor :keyword_ids

      # TODO:
      # identifiers

      def initialize(params)
        @recent = params[:recent].blank? ? false : true
        @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]
      end

      # @return [Arel::Table]
      def table
        ::CollectionObject.arel_table
      end

      def tag_table
        ::Tag.arel_table
      end

      # TODO: make generic
      def matching_keyword_ids
        return nil if keyword_ids.empty?
        o = table
        t = ::Tag.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = t.alias('t1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:tag_object_id])
          .and(c[:tag_object_type].eq(table.name.classify))
        )

        e = c[:keyword_id].not_eq(nil)
        f = c[:keyword_id].eq_any(keyword_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.as('tz5_')

        _a = ::CollectionObject.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def matching_shape
        return nil if shape.nil?

        geometry = shape.geometry
        this_type = geometry.geometry_type.to_s.downcase
        geometry = geometry.as_text
        radius = shape['radius'] || 100

        case this_type
        when 'point'
          ::CollectionObject
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(geometry, radius ))
        when 'polygon'
          ::CollectionObject
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(geometry))
        else
          nil
        end
      end 
   
      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
        # clauses += attribute_clauses
       
        clauses += [
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
          matching_keyword_ids,
          # matching_shape,
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

        q = nil 
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::CollectionObject.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::CollectionObject.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end
  
      protected

    end
  end
end
