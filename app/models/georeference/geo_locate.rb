# A Georeference derived from a call to the Tulay GeoLocate API.
class Georeference::GeoLocate < Georeference
  attr_accessor :api_response
  
  REQUEST_PARAMS = {
    country:      nil,   # name of a country 'USA', or Germany
    state:        nil,   # 'IL', or 'illinois' (required in the United States)
    county:       nil,   # upply as a parameter, returned as 'Adm=' 
    locality:     nil,   # name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
    hwyX:         'false',
    enableH2O:    'false',
    doUncert:     'true',
    doPoly:       'false',
    displacePoly: 'false',
    languageKey:  '0',
    fmt:          'json'   # or geojson ?
  }

  def api_response=(response)
    make_geographic_item(response.result)
    make_error_geographic_item(response.result)
  end

  def request_hash
    Hash[*self.api_request.split('&').collect { |a| a.split('=', 2) }.flatten]
  end

   def make_geographic_item(result)
    p                          = result['resultSet']['features'][0]['geometry']['coordinates']
    self.geographic_item       = GeographicItem.new
    self.geographic_item.point = Georeference::FACTORY.point(p[0], p[1])
  end

  def make_error_geographic_item(result)
    # evaluate for error_radius only if called for (default)
    er = result['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']
    self.error_radius = (er ? er : 3.0)

    #evaluate for error polygon only if called for (non-default)
    if  result['resultSet']['features'][0]['properties']['uncertaintyPolygon'] #     @request[:doPoly]
      # Build the error geographic shape
      # isolate the array of points from the response, and build the polygon from a line_string
      # made out of the points
      p         = result['resultSet']['features'][0]['properties']['uncertaintyPolygon']['coordinates'][0]
      # build an array of Georeference::FACTORY.points from p

      # poly = 'MULTIPOLYGON(((' + p.collect{|a,b| "#{a} #{b}"}.join(',') + ')))'
      # parsed_poly = Georeference::FACTORY.parse_wkt(poly)
     
      err_array = []
      # TODO: get geoJson results and handle all this automatically? 
      p.each { |point| err_array.push(Georeference::FACTORY.point(point[0], point[1])) }
      self.error_geographic_item         = GeographicItem.new
      self.error_geographic_item.polygon = Georeference::FACTORY.polygon(Georeference::FACTORY.line_string(err_array))
    else
      # this may not be strictly necessary...
      self.error_geographic_item = nil
    end
  end

  def self.build(request_params)

    gl = self.new

    # TODO: write a Request.valid_params? method to use here
    if request_params.nil?
      gl.errors.add(:base, 'invalid or no request parameters provided.')
      return gl
    end

    request = Request.new(request_params)
    request.locate
    
    if request.succeeded?
      gl.api_response = request.response
      gl.api_request  = request.request_param_string 
    else
      gl.errors.add(:api_request, 'requested parameters did not succeed to return a result')
    end

    gl
  end

  class Request
    URI_HOST = 'www.museum.tulane.edu'  
    URI_PATH = '/webservices/geolocatesvcv2/glcwrap.aspx?'

    attr_accessor :succeeded
    attr_reader :request_params, :response, :request_param_string 
    def initialize(request_params)
      @request_params = Georeference::GeoLocate::REQUEST_PARAMS.merge(request_params) 
      @succeeded = nil
    end

    def locate 
      @response = Georeference::GeoLocate::Response.new(self)
    end

    def build_param_string
      @request_param_string ||= @request_params.collect{ |key, value| "#{key}=#{value}" }.join('&')
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
      @result = JSON.parse(call_api(Georeference::GeoLocate::Request::URI_HOST, request))
      request.succeeded = true if @result['numResults'].to_i > 0 
    end

    protected 

    def call_api(host, request)
      Net::HTTP.get(host, request.request_string)
    end
  end

end
