module Vendor
  module Rgeo
    def self.coord_sys_is_wgs84?(cs)
      # TODO: what else could a valid cs.name for WGS 84 be?
      wgs84_names = ['EPSG:4326', 'WGS 84', 'GCS_WGS_1984']

      cs.geographic? &&
        ((cs.name.present? && wgs84_names.include?(cs.name)) ||
        (cs.authority_code.present? && cs.authority_code == '4326'))
    end

  end
end
