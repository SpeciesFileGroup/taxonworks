module Queries
  module AssertedDistribution

   # TODO: 
   #   add geographic_area_mode
   #   inherit from queries
   #   add annotations

    # !! does not inherit from base query
    class Filter < Query::Filter

      include Queries::Concerns::Citations
      include Queries::Concerns::Users

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :otu_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_area_id

      # @return [Boolean, nil]
      #   How to treat GeographicAreas
      #     nil - non-spatial match by only those records matching the geographic_area_id exactly
      #     true - spatial match
      #     false - non-spatial match (descendants)
      attr_accessor :geographic_area_mode

      attr_accessor :wkt

      attr_accessor :geo_json

      # @return [Boolean, nil]
      #   nil - both
      #   true - only 't'
      #   false - only 'f'
      attr_accessor :presence

      # @return Array
      # @param [taxon name ids, nil]
      #   all Otus matching these taxon names
      attr_accessor :taxon_name_id
      
      # @return [Boolean, nil]
      #  true - include descendants of taxon_name_id in scope
      #  false, nil - only exact matches
      attr_accessor :descendants

      # Add citations extension

      # @param sourceid [Array, Integer, String]
      # @return [Array]
      # attr_accessor :source_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      # attr_accessor :is_original

      # TODO: replicate the TaxonName Parenthood params here
      # attr_accessor ancestor

      def initialize(params)
        @otu_id = params[:otu_id]
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        
        @taxon_name_id = params[:taxon_name_id]
        @descendants = boolean_param(params, :descendants)

        @geographic_area_mode = boolean_param(params, :geographic_area_mode)

        @wkt = params[:wkt]
        @geo_json = params[:geo_json]

        @presence = boolean_param(params, :presence)
        @recent = boolean_param(params, :recent)

        set_user_dates(params)
        set_citations_params(params)
        super
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      # @return [Arel::Table]
      def table
        ::AssertedDistribution.arel_table
      end

      def base_query
        ::AssertedDistribution.select('asserted_distributions.*')
      end

      def asserted_distribution_attribute_equals(attribute)
        a = send(attribute)
        if a
          return a.empty? ? nil : table[attribute].eq_any(a)
        end
        nil
      end

      def presence_facet
        return nil if presence.nil?
        if presence 
          table[:is_absent].eq_any(['f', nil])
        else
          table[:is_absent].eq('t')
        end
      end

      # TODO - joins, not n+1
      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      # TODO: Withify
      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        byebug
        return nil if geo_json.nil?
        if i = spatial_query
         
          # All spatial records
          j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)

          # Expand to include all descendants of any spatial match!
          k = ::GeographicArea.descendants_of_any(j.pluck(:id))

          j ||= []
          k ||= []

          return ::AssertedDistribution.where(geographic_area: j + k )
        else
          return nil
        end
      end

      def spatial_query
        if geometry = RGeo::GeoJSON.decode(geo_json)
          case geometry.geometry_type.to_s
          when 'Point'
            # TODO:  radius = WHAT?
            ::GeographicItem.where(::GeographicItem.within_radius_of_wkt_sql(geometry.to_s, radius ) ) # TODO: FIX THIS, radius is not defined
          when 'Polygon', 'MultiPolygon'
            ::GeographicItem.where(::GeographicItem.contained_by_wkt_sql(geometry.to_s))
          else
            nil
          end
        else
          nil
        end
      end

      # !! TODO: "withify"
      def from_wkt(wkt_shape)

        i = ::GeographicItem.joins(:geographic_areas).where(::GeographicItem.contained_by_wkt_sql(wkt_shape))
        j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)

        k = ::GeographicArea.descendants_of(j) # Add children that might not be caught because they don't have a shapes

        ::AssertedDistribution.where(geographic_area: j + k) # .or.where(geographic_area: k)
      end

      def geographic_area_id_facet 
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        b = nil # from AssertedDistributions 
        
        case geographic_area_mode
        when nil, false # exact, descendants
          b = ::AssertedDistribution.where(geographic_area: a) 
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['collection'].to_s # todo, check
          return from_wkt(wkt_shape)
        end
       
        b
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          o = Arel::Table.new(:otus)

          j = o.join(h, Arel::Nodes::InnerJoin).on(o[:taxon_name_id].eq(h[:descendant_id]))
          z = h[:ancestor_id].eq_any(taxon_name_id)
          
          ::AssertedDistribution.joins(:otu).joins(j.join_sources).where(z)
        else
          ::AssertedDistribution.joins(:otu).where(otus: {taxon_name_id: taxon_name_id})
        end
      end

      def base_and_clauses
        clauses = []
        clauses += [
          presence_facet,
          asserted_distribution_attribute_equals(:otu_id),  # TODO: handles array?multiple?  
        ].compact
      end

      def base_merge_clauses
        clauses = []
        clauses +=
          [
            created_updated_facet, # See Queries::Concerns::Users
            taxon_name_id_facet,
            geographic_area_id_facet,
            wkt_facet,
            geo_json_facet,
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
      def and_clauses
        clauses = base_and_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def all
        a = and_clauses
        b = merge_clauses
        q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q =  ::AssertedDistribution.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::AssertedDistribution.all
        end

        # q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end

      protected

    end
  end
end
