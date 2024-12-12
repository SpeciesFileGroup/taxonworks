module Vendor
  module Rgeo
    # @param cs RGeo::CoordSys
    # @return [Integer] (Likely) EPSG of the cs, if one could be determined;
    #   raises TaxonWorks::Error if an EPSG couldn't be determined.
    # !! Uses postgis table spatial_ref_sys.
    def self.epsg_for_coord_sys(cs)
      if coord_sys_is_wgs84?(cs)
        return 4326
      end

      proj4 = RGeo::CoordSys::Proj4.create(cs.to_s)
      # spatial_ref_sys doesn't include '+type=crs' in its values, so remove that:
      proj4 = proj4.canonical_str.sub('+type=crs', '').squeeze(' ').strip
      result = ActiveRecord::Base.connection.select_all(
        # Would rather not need ILIKE here but at time of writing some
        # proj4text entries had a trailing space, e.g. 4267.
        # TODO not very sophisticated: we're matching entire strings, not
        # individual terms of the proj4
        "SELECT auth_srid, proj4text FROM spatial_ref_sys WHERE auth_name='EPSG' AND proj4text ILIKE '%#{proj4}%'"
      )

      matches = result.filter { |r|
        / *#{Regexp.escape(proj4)} */.match?(r['proj4text'])
      }

      if matches.empty?
        raise TaxonWorks::Error,
          "Unable to determine EPSG for non-WGS84 prj file: '#{proj4}'"
      elsif matches.count > 1
        raise TaxonWorks::Error,
          "Unable to determine a unique EPSG for non-WGS84 prj file, choices are: '#{matches.map{ |r| r['auth_srid'] }.join(', ')}'"
      end

      matches.first['auth_srid']
    end

    def self.coord_sys_is_wgs84?(cs)
      # TODO: what else could a valid cs.name for WGS 84 be?
      wgs84_names = ['EPSG:4326', 'WGS 84', 'GCS_WGS_1984']

      cs.geographic? &&
        ((cs.name.present? && wgs84_names.include?(cs.name)) ||
        (cs.authority_code.present? && cs.authority_code == '4326'))
    end

  end
end
