class Georeference::GeoLocate < Georeference
  #require 'json'
  attr_accessor :response
  attr_accessor :request

  # These are fine here
  URI_HOST = 'www.museum.tulane.edu'
  URI_PATH = '/webservices/geolocatesvcv2/glcwrap.aspx?'

=begin

g = Georeference::GeoLocate.new
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

  def initialize(params = {})
    if params != {}
      @request = params[:request]
      params.delete(:request)
    end
    super
    @response = nil
    @request  ||= {}
    build if @request != {}
  end

  def request_hash
    Hash[*self.api_request.split('&').collect { |a| a.split('=', 2) }.flatten]
  end

  def build
    if @request.keys.size > 0
      locate
      if @response['numResults'] > 0
        build_geographic_item
        build_error_geographic_item
      else
        errors.add(:api_request, 'requested parameters returned no results')
      end
    else
      errors.add(:base, 'no request paramaters provided')
    end
  end

  def locate
    if self.build_request
      get_response
    end
  end

  def build_request
    # TODO: validation: if country is some form of 'USA', a state is required
    # TODO: options can be added: county, hwyX, etc.
    opts             = {
      country:      nil,
      state:        nil,
      county:       nil,
      locality:     nil,
      hwyX:         'false',
      enableH2O:    'false',
      doUncert:     'true',
      doPoly:       'false',
      displacePoly: 'false',
      languageKey:  '0',
      fmt:          'json'
    }.merge!(@request)

    # TODO: write actual validation
    # if valid == true
    self.api_request = opts.collect { |key, value| "#{key}=#{value}" }.join('&')
    #  true
    # else
    #  errors.add(:api_request, 'invalid request parameters')
    #  false
    # end
  end

  def call_api
    Net::HTTP.get(URI_HOST, URI_PATH + self.api_request)
  end

  def get_response
    @response = JSON.parse(self.call_api)
  end

  def build_geographic_item
    p                          = @response['resultSet']['features'][0]['geometry']['coordinates']
    self.geographic_item       = GeographicItem.new
    self.geographic_item.point = Georeference::FACTORY.point(p[0], p[1])
  end

  def build_error_geographic_item
    self.error_radius = @response['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']
    # Build the error geographic shape
    # isolate the array of points from the response, and build the polygon from a line_string
    # made out of the points
    p                 = @response['resultSet']['features'][0]['properties']['uncertaintyPolygon']['coordinates'][0]
    # build an array of Georeference::FACTORY.points from p

    # TODO: could benchmark 
    # poly = 'MULTIPOLYGON(((' + p.collect{|a,b| "#{a} #{b}"}.join(',') + ')))'
    # parsed_poly = Georeference::FACTORY.parse_wkt(poly)

    err_array         = []
    p.each { |point| err_array.push(Georeference::FACTORY.point(point[0], point[1])) }
    self.error_geographic_item         = GeographicItem.new
    self.error_geographic_item.polygon = Georeference::FACTORY.polygon(Georeference::FACTORY.line_string(err_array))
  end
end
