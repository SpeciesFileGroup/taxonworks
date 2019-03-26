module Queries
  module TaxonName 

    # !! does not inherit from base query
    class Filter << Queries::Query

      include Queries::Concerns::Tags
      
      attr_accessor :type

      attr_accessor :nomenclature_group

      # []
      attr_accessor :parent_id

      attr_accessor :exact

      attr_accessor :as_object

      attr_accessor :as_subject

      attr_accessor :status
      
      attr_accessor :keyword_ids

      attr_accessor :valid

      def initialize(params)
     end

      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end

      def matching_shape
        return nil if shape.nil?

        geometry = shape.geometry
        this_type = geometry.geometry_type.to_s.downcase
        geometry = geometry.as_text
        radius = shape['radius'] || 100

        case this_type
        when 'point'
          ::TaxonName
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(geometry, radius ))
        when 'polygon'
          ::TaxonName
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(geometry))
        else
          nil
        end
      end 

      # TODO: throttle by size?
      def matching_spatial_via_geographic_area_ids
        return nil if spatial_geographic_area_ids.empty? 
        a = ::GeographicItem.default_by_geographic_area_ids(spatial_geographic_area_ids).ids 
        ::TaxonName.joins(:geographic_items).where( ::GeographicItem.contained_by_where_sql( a ) )
      end

      def matching_any_label
        return nil if in_labels.blank?
        t = "%#{in_labels}%"
        table[:verbatim_label].matches(t).or(table[:print_label].matches(t)).or(table[:document_label].matches(t))
      end

      def matching_verbatim_locality
        return nil if in_verbatim_locality.blank?
        t = "%#{in_verbatim_locality}%"
        table[:verbatim_locality].matches(t)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
        clauses += attribute_clauses
       
        clauses += [
          between_date_range,
          matching_any_label,
          matching_verbatim_locality,
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
          matching_shape,
          matching_spatial_via_geographic_area_ids

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

        q = nil 
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::TaxonName.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::TaxonName.all
        end

        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
  
      protected

    end
  end
end
