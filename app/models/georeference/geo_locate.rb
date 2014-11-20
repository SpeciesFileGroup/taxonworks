# A Georeference derived from a call to the Tulay GeoLocate API.
class Georeference::GeoLocate < Georeference
  attr_accessor :api_response, :iframe_response

  URI_HOST = 'www.museum.tulane.edu'
  URI_PATH = '/webservices/geolocatesvcv2/glcwrap.aspx?'

  def api_response=(response)
    make_geographic_item(response.coordinates)
    make_error_geographic_item(response.uncertainty_polygon, response.uncertainty_radius)
  end

  def iframe_response=(response_string)
    lat, long, error_radius, uncertainty_points = Georeference::GeoLocate.parse_embedded_result(response_string)
    make_geographic_item([long, lat])
    make_error_geographic_item(uncertainty_points, error_radius)
  end

  def request_hash
    Hash[*self.api_request.split('&').collect { |a| a.split('=', 2) }.flatten]
  end

  # coordinates is an Array of Stings of [longitude, latitude]
  def make_geographic_item(coordinates)
    self.geographic_item = GeographicItem.new(point: Georeference::FACTORY.point(coordinates[0], coordinates[1]))
  end

# def make_error_geographic_item(result)
#   # evaluate for error_radius only if called for (default)
#   er = result['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']
#   self.error_radius = (er ? er : 3.0)

#   #evaluate for error polygon only if called for (non-default)
#   if  result['resultSet']['features'][0]['properties']['uncertaintyPolygon'] #     @request[:doPoly]
#     # Build the error geographic shape
#     # isolate the array of points from the response, and build the polygon from a line_string
#     # made out of the points
#     p         = result['resultSet']['features'][0]['properties']['uncertaintyPolygon']['coordinates'][0]
#     # build an array of Georeference::FACTORY.points from p

#     # poly = 'MULTIPOLYGON(((' + p.collect{|a,b| "#{a} #{b}"}.join(',') + ')))'
#     # parsed_poly = Georeference::FACTORY.parse_wkt(poly)

#     err_array = []
#     # TODO: get geoJson results and handle all this automatically? 
#     p.each { |point| err_array.push(Georeference::FACTORY.point(point[0], point[1])) }
#     self.error_geographic_item         = GeographicItem.new
#     self.error_geographic_item.polygon = Georeference::FACTORY.polygon(Georeference::FACTORY.line_string(err_array))
#   end
# end

  def make_error_geographic_item(uncertainty_polygon, uncertainty_radius = 3)
    self.error_radius = uncertainty_radius.to_i
    unless uncertainty_polygon.nil?
      err_array = []
      # TODO: get geoJson results and handle all this automatically?
      uncertainty_polygon.each { |point| err_array.push(Georeference::FACTORY.point(point[0], point[1])) }
      self.error_geographic_item = GeographicItem.new(polygon: Georeference::FACTORY.polygon(Georeference::FACTORY.line_string(err_array)))
    end
  end

  def self.build_from_embedded_result(response_string)
    # TODO: Add error adding
    self.new(iframe_response: response_string)
  end

  def self.parse_embedded_result(response_string)
    lat, long, error_radius, uncertainty_polygon = response_string.split("|")
    uncertainty_points                           = uncertainty_polygon.split(',').reverse.in_groups_of(2)
    [lat, long, error_radius, uncertainty_points]
  end

  # Build a georeference starting with a set of request parameters.
  def self.build(request_params)
    g = self.new

    # TODO: write a Request.valid_params? method to use here
    # TODO: #1: Just what will be the validation criteria for the request?
    # TODO: #2: Why not judge validity from the response?
    if request_params.nil?
      g.errors.add(:base, 'invalid or no request parameters provided.')
      return g
    end

    request = Request.new(request_params)
    request.locate

    if request.succeeded?
      g.api_response = request.response
      g.api_request  = request.request_param_string
    else
      g.errors.add(:api_request, 'requested parameters did not succeed to return a result')
    end
    g
  end

  def self.default_options_string
    '&points=|||low|&georef=run|false|false|true|true|false|false|false|0&gc=Tester'
  end

  class RequestUI
    REQUEST_PARAMS = {
      country:       nil, # name of a country 'USA', or Germany
      state:         nil, # 'IL', or 'illinois' (required in the United States)
      county:        nil, # supply as a parameter
      locality:      nil, # name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
      Latitude:      nil, #
      Longitude:     nil, #
      Placename:     nil, #
      Score:         '0',
      Uncertainty:   '3',
      H20:           'false',
      HwyX:          'false',
      Uncert:        'true',
      Poly:          'true',
      DisplacePoly:  'false',
      RestrictAdmin: 'false',
      BG:            'false',
      LanguageIndex: '0',
      gc:            'Tester'
    }

    attr_reader :request_params, :request_param_string, :request_params_hash

    def initialize(request_params)
      @request_params = REQUEST_PARAMS.merge(request_params)
      @succeeded      = nil
    end

    def build_params_hash
      @request_params
    end

    def build_param_string
      @request_param_string ||= @request_params.collect { |key, value| "#{key}=#{value}" }.join('&')
    end

    def request_string
      build_param_string
      URI_PATH + @request_param_string
    end

    def request_hash

    end

  end

  class Request
    REQUEST_PARAMS = {
      country:      nil, # name of a country 'USA', or Germany
      state:        nil, # 'IL', or 'illinois' (required in the United States)
      county:       nil, # supply as a parameter, returned as 'Adm='
      locality:     nil, # name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
      enableH2O:    'false',
      hwyX:         'false',
      doUncert:     'true',
      doPoly:       'false',
      displacePoly: 'false',
      languageKey:  '0',
      fmt:          'json' # or geojson ?
    }

    attr_accessor :succeeded
    attr_reader :request_params, :response, :request_param_string

    def initialize(request_params)
      @request_params = REQUEST_PARAMS.merge(request_params)
      @succeeded      = nil
    end

    def locate
      @response = Georeference::GeoLocate::Response.new(self)
    end

    def build_param_string
      @request_param_string ||= @request_params.collect { |key, value| "#{key}=#{value}" }.join('&')
    end

    def request_string
      build_param_string
      URI_PATH + @request_param_string
    end

    def succeeded?
      @succeeded
    end

    def response
      @response ||= locate
    end

  end

  class Response
    attr_accessor :result

    def initialize(request)
      @result           = JSON.parse(call_api(Georeference::GeoLocate::URI_HOST, request))
      request.succeeded = true if @result['numResults'].to_i == 1
    end

    def coordinates
      @result['resultSet']['features'][0]['geometry']['coordinates']
    end

    def uncertainty_radius
      retval = @result['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']
      (retval == 'Unavailable') ? 3 : retval
    end

    def uncertainty_polygon
      retval = @result['resultSet']['features'][0]['properties']['uncertaintyPolygon']
      (retval == 'Unavailable') ? nil : retval['coordinates'][0]
    end

    protected

    def call_api(host, request)
      Net::HTTP.get(host, request.request_string)
    end
  end

end
