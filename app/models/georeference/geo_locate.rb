# A Georeference derived from a call to the Tulane GeoLocate API.
#
class Georeference::GeoLocate < Georeference
  attr_accessor :api_response, :iframe_response

  API_HOST       = 'www.geo-locate.org'.freeze
  API_PATH       = '/webservices/geolocatesvcv2/glcwrap.aspx?'.freeze
  EMBED_PATH     = '/web/webgeoreflight.aspx?'.freeze
  EMBED_HOST     = 'www.geo-locate.org'.freeze

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: "GEOLocate ",
      georeferenceRemarks: "Typically created by copy-pasting one or more values from a collecting event into a GEOLocate form.",
      georeferenceProtocol: 'Generated via a query through the GEOLocate web interface')
    h
  end

  # @param [Response] response
  # @return [RGeo object]
  def api_response=(response)
    self.geographic_item = make_geographic_point(response.coordinates[0], response.coordinates[1])
    make_error_geographic_item(response.uncertainty_polygon, response.uncertainty_radius)
  end

  # @param [String] response_string
  # @return [RGeo object]
  def iframe_response=(response_string)
    lat, long, error_radius, uncertainty_points = Georeference::GeoLocate.parse_iframe_result(response_string)
    self.geographic_item = make_geographic_point(long, lat, '0.0') unless (lat.blank? && long.blank?)
    if uncertainty_points.nil?
      # make a circle from the geographic_item
      unless error_radius.blank?
        # q1 = "SELECT ST_BUFFER('#{self.geographic_item.geo_object}', #{error_radius.to_f / 111319.444444444});"
        q2 = ActiveRecord::Base.send(:sanitize_sql_array, ['SELECT ST_Buffer(?, ?);',
                                                           self.geographic_item.geo_object.to_s,
                                                           (error_radius.to_f / 111_319.444444444)])
        value = GeographicItem.connection.select_all(q2).first['st_buffer']
        # circle                     = Gis::FACTORY.parse_wkb(value)
        # make_error_geographic_item([[long, lat], [long, lat], [long, lat]], error_radius)
        # a = GeographicItem.new(polygon: circle)
        # b = make_err_polygon(value)
        # self.error_geographic_item = a
        self.error_geographic_item = make_err_polygon(value)
      end
    else
      make_error_geographic_item(uncertainty_points, error_radius)
    end
    self.geographic_item
  end

  # @return [Hash] of api request pieces
  def request_hash
    Hash[*self.api_request.split('&').collect { |a| a.split('=', 2) }.flatten]
  end

  # @param [String] wkb
  # @return [GeographicItem::Polygon] GeographicItem::Polygon, either found, or created
  def make_err_polygon(wkb)
    polygon  = Gis::FACTORY.parse_wkb(wkb)
    # ActiveRecord::Base.send(:sanitize_sql_array, ['polygon = ST_GeographyFromText(?)', polygon.to_s])
    test_grs = GeographicItem::Polygon.where(['polygon = ST_GeographyFromText(?)', polygon.to_s])
    if test_grs.empty?
      test_grs = [GeographicItem.new(polygon: polygon)]
    end
    if test_grs.first.new_record?
      test_grs.first.save
    else
      test_grs.first
    end
    test_grs.first
  end

  # @param [String] x = longitude
  # @param [String] y = latitude
  # @param [String] z = elevation, defaults to 0.0
  # @return [Object] GeographicItem::Point, either found or created.
  def make_geographic_point(x, y, z = '0.0')
    if x.blank? || y.blank?
      test_grs = []
    else
      test_grs = GeographicItem::Point
                   .where("point = ST_GeographyFromText('POINT(? ? ?)')", x.to_f, y.to_f, z.to_f)
                   # .where(['ST_Z(point::geometry) = ?', z.to_f])
    end
    if test_grs.empty? # put a new one in the array
      test_grs = [GeographicItem.new(point: Gis::FACTORY.point(x, y, z))]
    end
    test_grs.first
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
  #     # build an array of Gis::FACTORY.points from p

  #     # poly = 'MULTIPOLYGON(((' + p.collect{|a,b| "#{a} #{b}"}.join(',') + ')))'
  #     # parsed_poly = Gis::FACTORY.parse_wkt(poly)

  #     err_array = []
  #     # @todo get geoJson results and handle all this automatically?
  #     p.each { |point| err_array.push(Gis::FACTORY.point(point[0], point[1])) }
  #     self.error_geographic_item         = GeographicItem.new
  #     self.error_geographic_item.polygon = Gis::FACTORY.polygon(Gis::FACTORY.line_string(err_array))
  #   end
  # end


  # @todo get geoJson results and handle all this automatically?
  # @param [RGeo::Polygon] uncertainty_polygon
  # @param [Integer] uncertainty_radius in meters
  def make_error_geographic_item(uncertainty_polygon, uncertainty_radius)
    self.error_radius = uncertainty_radius if !uncertainty_radius.nil?
    unless uncertainty_polygon.nil?
      err_array = []
      uncertainty_polygon.each { |point| err_array.push(Gis::FACTORY.point(point[0], point[1])) }
      self.error_geographic_item =
        GeographicItem.new(polygon: Gis::FACTORY.polygon(Gis::FACTORY.line_string(err_array)))
    end
  end

  # @param [String] response_string from Tulane
  # @return [Array]
  # parsing the four possible bits of a response into an array
  def self.parse_iframe_result(response_string)
    s = unify_response_string(response_string)
    lat, long, error_radius, uncertainty_polygon = s.split('|')
    uncertainty_points = nil
    unless uncertainty_polygon.nil?
      if uncertainty_polygon =~ /unavailable/i # todo: there are many more possible error conditions
        uncertainty_points = nil
      else
        uncertainty_points = uncertainty_polygon.split(',').reverse.in_groups_of(2)
      end
    end
    [lat, long, error_radius, uncertainty_points]
  end

  # TODO: move ti iframe getter/setter
  def self.unify_response_string(response_string)
    response_string.gsub!(/[\t]/, '|')
    response_string.gsub!(/\s+/, '|')
    response_string
  end

  # Build a georeference starting with a set of request parameters.
  # @param [ActionController::Parameters] request_params
  # @return [GeoLocate]
  def self.build(request_params)
    g = self.new

    # @todo write a Request.valid_params? method to use here
    # @todo #1: Just what will be the validation criteria for the request?
    # @todo #2: Why not judge validity from the response?
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
      g.errors.add(:api_request, 'requested parameters did not succeed in returning a result')
    end
    g
  end

  # def self.default_options_string
  #   '&points=|||low|&georef=run|false|false|true|true|false|false|false|0&gc=Tester'
  # end

  #rubocop:disable Style/StringHashKeys
  # This class is used to create the string which will be sent to Tulane
  class RequestUI
    REQUEST_PARAMS = {
      'country'       => nil, # name of a country 'USA', or Germany
      'state'         => nil, # 'IL', or 'illinois' (required in the United States)
      'county'        => nil, # supply as a parameter
      'locality'      => nil, # name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
      'Latitude'      => nil, #
      'Longitude'     => nil, #
      'Placename'     => nil, #
      'Score'         => '0',
      'Uncertainty'   => '3',
      'H20'           => 'false',
      'HwyX'          => 'false',
      'Uncert'        => 'true',
      'Poly'          => 'true',
      'DisplacePoly'  => 'false',
      'RestrictAdmin' => 'false',
      'BG'            => 'false',
      'LanguageIndex' => '0',
      'gc'            => 'TaxonWorks'
    }.freeze
    #rubocop:enable Style/StringHashKeys

    attr_reader :request_params, :request_params_string, :request_params_hash

    # @param [ActionController::Parameters] request_params
    def initialize(request_params)
      @request_params_hash = REQUEST_PARAMS.merge(request_params)
      build_param_string
      @succeeded = nil
    end

    # "http://www.geo-locate.org/web/webgeoreflight.aspx?country=United States of
    # America&state=Illinois&locality=Champaign&points=40.091622
    # |-88.241179|Champaign|low|7000&georef=run|false|false|true|true|false|false|false|0&gc=Tester"
    # @return [String] a string to invoke as an api call to hunt for a particular place.
    def build_param_string
      # @request_param_string ||= @request_params.collect { |key, value| "#{key}=#{value}" }.join('&')
      ga                     = request_params_hash
      params_string          = 'http://' + EMBED_HOST + EMBED_PATH +
        "country=#{ga['country']}&state=#{ga['state']}&county=#{ga['county']}&locality=#{ga['locality']}&points=" \
        "#{ga['Latitude']}|#{ga['Longitude']}|#{ga['Placename']}|#{ga['Score']}|#{ga['Uncertainty']}" \
        "&georef=run|#{ga['H20']}|#{ga['HwyX']}|#{ga['Uncert']}|#{ga['Poly']}|#{ga['DisplacePoly']}|" \
        "#{ga['RestrictAdmin']}|#{ga['BG']}|#{ga['LanguageIndex']}" \
        "&gc=#{ga['gc']}"
      @request_params_string = params_string # URI.encode(params_string)
    end

    # def request_string
    #   build_param_string
    #   URI_PATH + @request_param_string
    # end
    #
    # def request_hash
    #   @request_params_hash
    # end
    #
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
    }.freeze

    attr_accessor :succeeded
    attr_reader :request_params, :response, :request_param_string

    # @param [ActionController::Parameters] request_params
    def initialize(request_params)
      @request_params = REQUEST_PARAMS.merge(request_params)
      @succeeded      = nil
    end

    # sets the response attribute.
    def locate
      @response = Georeference::GeoLocate::Response.new(self)
    end

    # sets the @request_param_string attribute.
    def build_param_string
      @request_param_string ||= @request_params.collect { |key, value| "#{key}=#{value}" }.join('&')
    end

    # @return [String] api request string.
    def request_string
      build_param_string
      API_PATH + @request_param_string
    end

    # @return [Boolean] true if request was successful
    def succeeded?
      @succeeded
    end

    # @return [Georeference::GeoLocate::Response]
    def response
      @response ||= locate
    end
  end

  class Response
    attr_accessor :result

    # @param [JSON object] request
    def initialize(request)
      @result           = JSON.parse(call_api(Georeference::GeoLocate::API_HOST, request))
      request.succeeded = true if @result['numResults'].to_i > 0
    end

    # @return [String] coordinates from the response set.
    def coordinates
      @result['resultSet']['features'][0]['geometry']['coordinates']
    end

    # @return [String] uncertainty_radius from the response set.
    def uncertainty_radius
      retval = @result['resultSet']['features'][0]['properties']['uncertaintyRadiusMeters']
      (retval == 'Unavailable') ? 3 : retval
    end

    # @return [String] uncertainty_polygon from the response set.
    def uncertainty_polygon
      retval = @result['resultSet']['features'][0]['properties']['uncertaintyPolygon']
      (retval == 'Unavailable') ? nil : retval['coordinates'][0]
    end

    protected

    # @param [String] host domain name
    # @param [String] request string.
    # @return [HTTP object]
    def call_api(host, request)
      Net::HTTP.get(host, request.request_string)
    end
  end
end
