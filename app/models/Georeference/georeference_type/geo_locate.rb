class Georeference::GeoreferenceType::GeoLocate < Georeference::GeoreferenceType
  #require 'json'

  # TODO: These constants perhaps should be initialized in lib/tulane.rb
  URI_HOST = 'www.museum.tulane.edu'
  URI_PATH = '/webservices/geolocatesvcv2/glcwrap.aspx'

  result = {}
=begin

g = Georeference::GeoreferenceType::GeoLocate.new
g.locate('USA', 'Champaign', 'IL')

  Things to build a request:

  r = JSON.parse(Net::HTTP.get('www.museum.tulane.edu', '/webservices/geolocatesvcv2/glcwrap.aspx?Country=USA&Locality=champaign&state=illinois&dopoly=true'))

  request => text from '?' to end of request
  '?country=usa&locality=champaign&state=illinois&dopoly=true'

  locality => name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
  country => name of a country 'USA', or Germany
  state => 'IL', or 'illinois' (required in the United States)
  county => supply as a parameter, returned as 'Adm='
  hwyX
  enableH2O
  doUncert
  doPoly
  displacePoly
  languageKey
  fmt => JSON or GeoJSON

=end

  def locate(country, locality, state)
    # TODO: validation: if country is some form of 'USA', a state is required
    # TODO: options can be added: county, hwyX, etc.

    # 'request' will be stored in the grandparent

    self.request = "?country=#{country}&locality=#{locality}&state=#{state}&dopoly=true"
    result = JSON.parse(Net::HTTP.get(URI_HOST, URI_PATH + request))

    if result['numResults'] > 0
      # TODO: there may be cases of more than one
      self.parse_to_grandparent(result)
    else
      puts "Request = \'#{self.request}\': insufficient data."
    end

    # TODO: return validation: check to see what the return was.  Right not
  end

  def parse_to_grandparent(result)

    # TODO: what is the name of the global GeoFactory?
    twf = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_z_coordinate: true)
    p = result['resultSet']['features'][0]['geometry']['coordinates']

    # 'self' is how one gets to the attributes of the grandparent?
    #
    # This is the point which will become the object for the grandparent's 'geographic_item_id'.

    v = GeographicItem.new

    v.point = twf.point(p[0], p[1])
    v.save

    self.geographic_item_id = v.id
    # This will become grandparent's error_radius

    self.error_radius = result['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']

    # isolate the array of points from the result, and build the polygon from a line_string
    # made out of the points

    p = result['resultSet']['features'][0]['properties']['uncertaintyPolygon']['coordinates'][0]

    # build an array of twf.points from p
    err_array = []
    p.each {|point| err_array.push(twf.point(point[0], point[1]))}

    # This will become the object for the grandparent's 'error_geographic_item_id'

    v = GeographicItem.new

    v.polygon = twf.polygon(twf.line_string(err_array))
    v.save

    self.error_geographic_item_id = v.id

  end
end
