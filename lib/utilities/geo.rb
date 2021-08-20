# General purpose Geo related methods
module Utilities
  # Special general routines for Geo-specific itams
  module Geo
=begin
To add a new (discovered) symbol:
  1) To find the Unicode string for any character, use Utilities::Geo.uni_string('c') (remove the first '\').
  2) Add the Unicode string (i.e, "\uNNNN") to SPECIAL_LATLONG_SYMBOLS (below), selecting either degrees
      (starting with 'do*'), or tickmarks (starting at "'").
  3) Add the Unicode to the proper section in the regexp in the corresponding section (degrees, minutes, or seconds).
      NB: all the minutes symbols are duplicated in the seconds section because sometimes two successive tickmarks
          (for minutes) are used for seconds.
=end
    # degree symbols, in addition to 'd', 'o', and '*'
    # \u00b0  "°"  \u00ba  "º"  \u02da  "˚"  \u030a  "?"  \u221e "∞"  \u222b "∫"
    #
    # tick symbols, in addition to "'" ("\u0027""), and '"' ("\u0022")
    # \u00a5  "¥"  \u00b4  "´"
    # \u02B9  "ʹ"  \u02BA  "ʺ"  \u02BB  "ʻ"  \u02BC  "ʼ"  \u02CA "ˊ"
    # \u02EE  "ˮ"  \u2032  "′"  \u2033  "″"
    # \u2019  "’"  \u201D  "”"    added June 2020
    #
    # Significant figures/digits: any of the digits of a number beginning with the digit farthest to the left
    # that is not zero and ending with the last digit farthest to the right that is either not zero
    # or that is a zero but is considered to be exact

    SPECIAL_LATLONG_SYMBOLS = "do*\u00b0\u00ba\u02DA\u030a\u221e\u222b\u0027\u00b4\u02B9\u02BA\u02BB\u02BC\u02CA\u02EE\u2032\u2033\u0022\u2019\u201D".freeze

    LAT_LON_REGEXP = Regexp.new(/(?<lat>-?\d+\.?\d*),?\s*(?<long>-?\d+\.?\d*)/)

    # DMS_REGEX = "(?<degrees>-*\d+)[do*\u00b0\u00ba\u02DA\u030a\u221e\u222b]\s*(?<minutes>\d+\.*\d*)
    # [\u0027\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032]*\s*((?<seconds>\d+\.*\d*)
    # [\u0027\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\u0022]+)*"

    # http://en.wikiversity.org/wiki/Geographic_coordinate_conversion
    # http://stackoverflow.com/questions/1774985/converting-degree-minutes-seconds-to-decimal-degrees
    # http://stackoverflow.com/questions/1774781/how-do-i-convert-coordinates-to-google-friendly-coordinates

    # POINT_ONE_DIAGONAL = 15690.343288662 # 15690.343288662  # Not used?
    # TEN_WEST           = 1113194.90779206  # Not used?
    # TEN_NORTH          = 1105854.83323573  # Not used?

    # EARTH_RADIUS       = 6371000 # km, 3959 miles (mean Earth radius) # Not used?
    # RADIANS_PER_DEGREE = ::Math::PI/180.0
    # DEGREES_PER_RADIAN = 180.0/::Math::PI

    ONE_WEST       = 111_319.490779206 # meters/degree
    # ONE_WEST  = 111_319.444444444 # meters/degree (calculated mean)
    ONE_NORTH      = 110_574.38855796 # meters/degree

    #
    # class ConvertToDecimalDegrees
    #   attr_reader(:dd, :dms)
    #
    #   # @param [String] coordinate
    #   def initialize(coordinate)
    #     @dms = coordinate
    #     @dd  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(coordinate)
    #   end
    # end

    class CoordinatesFromLabel
      attr_reader(:verbatim_label, :coordinates)

      # @param [String] label
      def initialize(label)
        @verbatim_label = label
        @coordinates = Utilities::Geo.coordinates_regex_from_verbatim_label(label)
      end
    end

    # 12345       (presume meters)
    # 123.45
    # 123 ft > 123 ft. > 123 feet > 1 foot > 123 f > 123 f.
    # 123 m > 123 meters > 123 m.
    # 123 km > 123 km. > 123 kilometers
    # 123 mi > 123 milee > 123 miles
    #
    # @param [String] dist_in
    # @return [String]      #     ##### changed from previous type
    def self.distance_in_meters(dist_in)
      dist_in   = '0.0 meters' if dist_in.blank?
      elevation = dist_in.strip.downcase
      pieces    = elevation.split(' ')
      # value     = elevation.to_f
      if pieces.count > 1 # two pieces, second is distance unit
        piece = 1
      else # one piece, may contain distance unit.
        piece = 0
      end
      value = pieces[0]
      scale = 1 # default is meters

      /(?<ft>f[oe]*[t]*\.*)|(?<m>[^k]m(eters)*[\.]*)|(?<km>kilometer(s)*|k[m]*[\.]*)|(?<mi>mi(le(s)*)*)/ =~ pieces[piece]
      # scale = $&

      scale = 1 unless m.blank?    # previously 1.0
      scale = 0.3048 unless ft.blank?
      scale = 1000 unless km.blank? # previously 1000.0
      scale = 1_609.344 unless mi.blank?

      value_sig = significant_digits(value.to_s)
      if value_sig[0].include?('.')
        s_value = value_sig[0].to_f
      else
        s_value = value_sig[0].to_i
      end
      s_sig = value_sig[1]

      distance = s_value * scale
      distance = conform_significant(distance.to_s, s_sig)  ####### previously .to_f
      distance
    end
=begin
    #  ' = \u0027, converted so that the regex can be used for SQL
    REGEXP_COORD_1 = {
      # tt1: /\D?(?<lat>\d+\.\d+\s*(?<ca>[NS])*)\s(?<long>\d+\.\d+\s*(?<co>[EW])*)/i,
      dd1a: /(\d+\.\d+\s*([NS]))\s*(\d+\.\d+\s*([EW]))/i,

      dd1b: /(([NS])\s*\d+\.\d+)\s*(([EW])\s*\d+\.\d+\s*)/i,

      dd2:  /(\d+[\. ]\d+(\u0027?)\s*([NS]))[, ]?\s*(\d+[\. ]\d+(\u0027?)\s*([EW]))/i,

      dm1:  /\D(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.|,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])? ?([NS])[\.,;]? ?(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.|,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])? ?([WE])\W/i,

      dms2: /\W([NS])\.? ?(\d+) ?([\*°ººo\u02DA ]) ?(\d+) ?([ ´\u0027\u02B9\u02BC\u02CA]) ?(\d+[\.|,]\d+|\d+) ?([ ""´\u02BA\u02EE\u0027\u02B9\u02BC\u02CA])([´\u0027\u02B9\u02BC\u02CA])?[\.,;]? ?([WE])\.? ?(\d+) ?([\*°ººo\u02DA ]) ?(\d+) ?([ \u0027´\u02B9\u02BC\u02CA]) ?(\d+[\.|,]\d+|\d+) ?([ ""´\u02BA\u02EE\u0027\u02B9\u02BC\u02CA])?([´\u0027\u02B9\u02BC\u02CA])?/i,

      dm3:  /\W([NS])\.? ?(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.|,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])[\.,;]? ?([WE])\.? ?(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.|,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])?/i,

      dms4: /\D(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])? ?(\d+)(")? ?([NS])(\d+) ?([\*°ººo\u02DA ]) ?(\d+[\.,]\d+|\d+) ?([ ´\u0027\u02B9\u02BC\u02CA])? ?(\d+)(["\u0027])? ?([EW])/i,

      dd5:  /\W([NS])\.? ?(\d+[\.|,]\d+|\d+) ?([\*°ººo\u02DA ])[\.,;]?\s*([WE])\.? ?(\d+[\.|,]\d+|\d+) ?([\*°ººo\u02DA ])?/i,

      dd6:  /\D(\d+[\.|,]\d+|\d+) ?([\*°ººo\u02DA ]) ?([NS])[\.,;]?\s*(\d+[\.|,]\d+|\d+) ?([\*°ººo\u02DA ]) ?([WE])\W/i,

      dd7:  /\[(-?\d+[\.|,]\d+|\-?d+),.*?(-?\d+[\.|,]\d+|\-?d+)\]/i
    }.freeze
=end
    #  ' = \u0027, converted so that the regex can be used for SQL
    # Added Unicode right single (u2019) and double (u201D) quote as minutes seconds
    REGEXP_COORD   = {
        # tt1: /\D?(?<lat>\d+\.\d+\s*(?<ca>[NS])*)\s(?<long>\d+\.\d+\s*(?<co>[EW])*)/i,
        dd1a: {reg: /(?<lat>\d+\.\d+\s*[NS])\s*(?<long>\d+\.\d+\s*[EW])/i,
               hlp: 'decimal degrees, trailing ordinal, e.g. 23.23N  44.44W'},

        dd1b: {reg: /(?<lat>[NS]\s*\d+\.\d+)\s*(?<long>[EW]\s*\d+\.\d+)/i,
               hlp: 'decimal degrees, leading ordinal, e.g. N23.23  W44.44'},

        dd2:  {reg: /(?<lat>\d+[\. ]\d+\u0027?\s*[NS]),?\s*(?<long>\d+[\. ]\d+\u0027?\s*[EW])/i,
               hlp: "decimal degrees, trailing ordinal, e.g. 43.836' N, 89.258' W"},

        dm1:  {reg: /(?<lat>\d+\s*[\*°o\u02DA ](\d+[\.,]\d+|\d+)\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]?\s*[NS])[\.,;]?\s*(?<long>\d+\s*[\*°ºo\u02DA ](\d+[\.,]\d+|\d+)\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]?\s*[WE])/i,
               hlp: "degrees, decimal minutes, trailing ordinal, e.g. 45 54.2'N, 78 43.5'E"},

        dms2: {reg: /(?<lat>[NS]\.?\s*\d+\s*[\*°ºo\u02DA ]\s*\d+\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]\s*(\d+[\.,]\d+|\d+)\s*[ "´\u02BA\u02EE\u0027\u02B9\u02BC\u02CA\u201D][´\u0027\u02B9\u02BC\u02CA]?)[\.,;]?\s*(?<long>[WE]\.?\s*\d+\s*[\*°ºo\u02DA ]\s*\d+\s*[ \u0027´\u02B9\u02BC\u02CA\u2019]\s*(\d+[\.,]\d+|\d+)\s*[ "´\u02BA\u02EE\u0027\u02B9\u02BC\u02CA\u201D]?[´\u0027\u02B9\u02BC\u02CA]?)/i,
               hlp: "degrees, minutes, decimal seconds, leading ordinal, e.g. S42°5'18.1\" W88º11'43.3\""},

        dm3:  {reg: /(?<lat>[NS]\.?\s*\d+\s*[\*°ºo\u02DA ]\s*(\d+[\.,]\d+|\d+)\s*([ ´\u0027\u02B9\u02BC\u02CA\u2019]))[\.,;]?\s*(?<long>[WE]\.?\s*\d+\s*[\*°ºo\u02DA ]\s*(\d+[\.,]\d+|\d+)\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]?)/i,
               hlp: "degrees, decimal minutes, leading ordinal, e.g. S42º5.18' W88°11.43'"},

        dms4: {reg: /(?<lat>\d+\s*[\*°ºo\u02DA ]\s*(\d+[\.,]\d+|\d+)\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]?\s*(\d+[\.,]\d+|\d+)["\u201D]?\s*[NS])\s*(?<long>\d+\s*[\*°ºo\u02DA ]\s*(\d+[\.,]\d+|\d+)\s*[ ´\u0027\u02B9\u02BC\u02CA\u2019]?\s*(\d+[\.,]\d+|\d+)+["\u201D]?\s*[EW])/i,
               hlp: "degrees, minutes, decimal seconds, trailing ordinal, e.g. 24º7'2.0\"S65º24'13.1\"W"},

        dd5:  {reg: /(?<lat>[NS]\.?\s*(\d+[\.,]\d+|\d+)\s*[\*°ºo\u02DA ])[\.,;]?\s*(?<long>([WE])\.?\s*(\d+[\.,]\d+|\d+)\s*[\*°ºo\u02DA ]?)/i,
               hlp: 'decimal degrees, leading ordinal, e.g. S42.18° W88.34°'},

        dd6:  {reg: /(?<lat>(\d+[\.,]\d+|\d+)\s*[\*°ºo\u02DA ]\s*[NS])[\.,;]?\s*(?<long>(\d+[\.|,]\d+|\d+)\s*[\*°ºo\u02DA ]\s*[WE])/i,
               hlp: 'decimal degrees, trailing ordinal, e.g. 42.18°S 88.43°W'},

        dd7:  {reg: /\[(?<lat>-?\d+[\.,]\d+|\-?d+),.*?(?<long>-?\d+[\.,]\d+|\-?d+)\]/i,
               hlp: 'decimal degrees, no ordinal, specific format, e.g. [12.263, -49.398]'}
    }.freeze
    # @param [String] label
    # @param [String] filters
    # @return [Array] of possible coordinate strings
    def self.hunt_lat_long_full(label, filters = REGEXP_COORD.keys)
      trials = {}
      filters.each_with_index {|kee, _dex|
        kee_string         = kee.to_s.upcase
        trials[kee_string] = {}
        named              = REGEXP_COORD[kee][:reg].match(label)
        unless named.nil?
          trials[kee_string][:piece] = named[0]
          trials[kee_string][:lat]   = named[:lat]
          trials[kee_string][:long]  = named[:long]
          named
        end
        trials[kee_string][:method] = "text, #{kee_string}"
      }
      trials
    end

    # rubocop:disable Metrics/MethodLength, Metrics/BlockNesting
    # @param [String] label
    # @param [String] how
    # @return [Hash] of possible lat/long pairs
    def self.hunt_lat_long(label, how = ' ')
      if how.nil?
        pieces = [label]
      else
        pieces = label.split(how)
      end
      lat_long = {}
      pieces.each do |piece|
        # group of possible regex configurations
        # m = /(?<lat>\d+\.\d+\s*(?<ca>[NS])*)\s(?<long>\d+\.\d+\s*(?<co>[EW])*)/i =~ piece
        m = REGEXP_COORD[:dd1a][:reg].match(piece)
        if m.nil?
          piece.each_char do |c|
            next unless SPECIAL_LATLONG_SYMBOLS.include?(c)
            test = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(piece)
            unless test.nil?
              if test.to_f.is_a? Numeric
                # might be a lat/long
                lat_long[:piece] = piece
                if lat_long[:lat].nil?
                  lat_long[:lat] = piece
                else
                  lat_long[:long]  = piece
                  lat_long[:piece] = [lat_long[:lat], piece].join(how)
                end
              end
            end
            break
          end
        else
          lat_long[:piece] = m[0]
          lat_long[:lat]   = m[:lat]
          lat_long[:long]  = m[:long]
        end
      end
      lat_long
    end
    # rubocop:enable Metrics/MethodLength, Metrics/BlockNesting

    # @param [String] label
    # @param [Array] filters
    # @return [Array]
    def self.hunt_wrapper(label, filters = REGEXP_COORD.keys)

      trials = self.hunt_lat_long_full(label, filters)

      ';, '.each_char {|sep|
        trial = self.hunt_lat_long(label, sep)
        found = "#{trial[:piece]}"
        unless trial[:lat].nil? and !trial[:long].nil?
          _found = "(#{sep})" if found.blank?
        end
        trials["(#{sep})"] = trial.merge!(method: "(#{sep})")
      }
      trials
    end

    # @param [String] c as single character
    # @return [Boolean]
    def self.is_lat_long_special(c)
      SPECIAL_LATLONG_SYMBOLS.include?(c)
    end

    # rubocop:disable Metrics/MethodLength
    # 42∞5'18.1"S88∞11'43.3"W
    # S42∞5'18.1"W88∞11'43.3"
    # S42∞5.18'W88∞11.43'
    # 42∞5.18'S88∞11.43'W
    # S42.18∞W88.34∞
    # 42.18∞S88.43∞W
    # -12.263, 49.398
    #
    # 42:5:18.1N
    # 88:11:43.3W
    #
    # no limit test, unless there is a ordinal letter included
    #
    # @param [String] dms_in
    # @return [Float] decimal degrees
    def self.degrees_minutes_seconds_to_decimal_degrees(dms_in) # rubocop:disable Metrics/PerceivedComplexity !! But this is too complex :)
      match_string = nil
      # no_point     = false
      degrees      = 0.0
      minutes      = 0.0
      seconds      = 0.0

      # make SURE it is a string! Watch out for dms_in == -10
      dms_in       = dms_in.to_s
      dms          = dms_in.dup.upcase
      dms          = dms.gsub('DEG', 'º').gsub('DG', 'º')
      dms =~ /[NSEW]/i
      ordinal = $LAST_MATCH_INFO.to_s
      # return "#{dms}: Too many letters (#{ordinal})" if ordinal.length > 1
      # return nil if ordinal.length > 1
      dms     = dms.gsub!(ordinal, '').strip.downcase

      if dms.include? '.'
        no_point = false
        if dms.include? ':' # might be '42:5.1'
          /(?<degrees>-*\d+):(?<minutes>\d+\.*\d*)(:(?<seconds>\d+\.*\d*))*/ =~ dms
          match_string = $& # rubocop:disable Style/IdenticalConditionalBranches
        else
          # this will get over-ridden if the next regex matches
          /(?<degrees>-*\d+\.\d+)/ =~ dms
          match_string = $& # rubocop:disable Style/IdenticalConditionalBranches
        end
      else
        no_point = true
      end

      # >40°26′46″< >40°26′46″<
      dms.each_char {|c|
        next unless SPECIAL_LATLONG_SYMBOLS.include?(c)
        /^(?<degrees>-*\d{0,3}(\.\d+)*) # + or - three-digit number with optional '.' and additional decimal digits
            [do*\u00b0\u00ba\u02DA\u030a\u221e\u222b\uc2ba]*\s* # optional special degrees symbol, optional space
          (?<minutes>\d+\.*\d*)* # optional number, integer or floating-point
            ['\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032\uc2ba\u2019]*\s* # optional special minutes symbol, optional space
          ((?<seconds>\d+\.*\d*) # optional number, integer or floating-point
            ['\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\uc2ba"\u201D]+)* # optional special seconds symbol, optional space
        /x =~ dms # '/(regexp)/x' modifier permits inline comments for regexp
        match_string = $&
        break # bail on the first character match
      }
      degrees = dms.to_f if match_string.nil? && no_point

      # @match_string = $&
      degrees = degrees.to_f
      case ordinal
      when 'W', 'S'
        sign = -1.0
      else
        sign = 1.0
      end
      if degrees < 0
        sign    *= -1
        degrees *= -1.0
      end
      frac = ((minutes.to_f * 60.0) + seconds.to_f) / 3600.0
      dd   = (degrees + frac) * sign
      case ordinal
      when 'N', 'S'
        limit = 90.0
      else
        limit = 180.0
      end
      # return "#{dms}: Out of range (#{dd})" if dd.abs > limit
      return nil if dd.abs > limit || dd == 0.0
      dd.round(6).to_s
    end
    # rubocop:enable Metrics/MethodLength

    # @param [String] char as single character
    # @return [String]
    def uni_string(char)
      format('\\u%04X', char.ord)
      # "\\#{sprintf('u%04X', char.ord)}"
      # '\\u%04X' % [char.ord]
    end

    # rubocop:disable Metrics/MethodLength
    # @param [ActionController::Parameters] params
    # @return [Integer]
    def self.nearby_from_params(params)
      nearby_distance = params['nearby_distance'].to_i
      nearby_distance = CollectingEvent::NEARBY_DISTANCE if nearby_distance == 0

      decade = case nearby_distance.to_s.length
               when 1..2
                 10
               when 3
                 100
               when 4
                 1_000
               when 5
                 10_000
               when 6
                 100_000
               when 7
                 1_000_000
               when 8
                 10_000_000
               else
                 10
               end
      digit  = (nearby_distance.to_f / decade.to_f).round

      case digit
      when 0..1
        digit = 1
      when 2
        digit = 2
      when 3..5
        digit = 5
      when 6..10
        decade *= 10
        digit = 1
      end

      params['digit1'] = digit.to_s
      params['digit2'] = decade.to_s
      digit * decade
    end
    # rubocop:enable Metrics/MethodLength

    # confirm that this says that the error radius is one degree or smaller
    # @param [RGeo::Point] geo_object
    # @param [Integer] error_radius
    # @return [RGeo::Polygon]
    def self.error_box_for_point(geo_object, error_radius)
      # this limits the actual error_box to 10k FOR THIS TEST ONLY!
      error_radius = 10_000 if error_radius > 10_000
      p0      = geo_object
      delta_x = (error_radius / ONE_WEST) / Math.cos(p0.y * Math::PI / 180)
      delta_y = error_radius / ONE_NORTH

      Gis::FACTORY.polygon(
        Gis::FACTORY.line_string(
          [
            Gis::FACTORY.point(p0.x - delta_x, p0.y + delta_y), # northwest
            Gis::FACTORY.point(p0.x + delta_x, p0.y + delta_y), # northeast
            Gis::FACTORY.point(p0.x + delta_x, p0.y - delta_y), # southeast
            Gis::FACTORY.point(p0.x - delta_x, p0.y - delta_y) # southwest
          ]
        )
      )
    end

    # make a diamond 2 * radius tall and 2 * radius wide, with the reference point as center
    # NOT TESTED/USED
    # @return [RGeo::Polygon]
    def diamond_error_box
      p0      = geo_object
      delta_x = (error_radius / ONE_WEST) / Math.cos(p0.y * Math::PI / 180)
      delta_y = error_radius / ONE_NORTH

      retval = Gis::FACTORY.polygon(Gis::FACTORY.line_string(
        [Gis::FACTORY.point(p0.x, p0.y + delta_y), # north
         Gis::FACTORY.point(p0.x + delta_x, p0.y), # east
         Gis::FACTORY.point(p0.x, p0.y - delta_y), # south
         Gis::FACTORY.point(p0.x - delta_x, p0.y) # west
        ]))
      box    = RGeo::Cartesian::BoundingBox.new(Gis::FACTORY)
      box.add(retval)
      box.to_geometry
    end

    # determine number of significant digits in string input argument
    # @param [String] number_string
    # @return [Array] [<string with only significant digits>, count, <left of decimal>, decimal point string, <right of decimal lead zeros string>, <mantissa string>]
    def self.significant_digits(number_string)
      # is there a decimal point?
      intg = ''
      decimal_point_zeros = ''
      mantissa = ''
      decimal_lead_zeros = 0
      decimal_point = ''
      /(?<num>([0-9]*)(\.?)([0-9]*))/ =~ number_string
      if num.nil?
        raise
      end
      dp = num.index(".")
      if dp.nil?
        intg = num
        intgl = intg.sub(/^[0]+/,'')  # strip lead zeros
        if intgl.nil?
          intg = num
        end
        intgt = intg.sub(/0+$/, '')    # strip trailing zeros
        if intgt.nil?
          intg = intgl
        end
        # sig = intg.length
      else
        # make sure truly numeric
        decimal_point = '.'
        digits = num.split(".")
        if digits.length > 2
          raise   # or just ignore extra decimal point and beyond?
        else
          if digits[0].length > 0 # left of decimal ?
            intg = digits[0].sub(/^[0]+/,'')
            if intg.nil?
              intg = digits[0]
            end
          else
            intg = ''
          end
          mantissa = digits[1]
          unless digits[1].nil?
            if intg.length > 0  # have full case nn.mm
              sig = intg.length + mantissa.length
            else  # mantissa might have "leading" zeros
              decimal_lead_zeros = digits[1].length
              mantissa = digits[1].sub(/^[0]+/, '')
              if mantissa.nil?
                mantissa = digits[1]
              end
              decimal_lead_zeros = decimal_lead_zeros - mantissa.length
              decimal_point_zeros = decimal_point_zeros.rjust(decimal_lead_zeros, '0')
            end
          else
            mantissa = ''
          end
        end
      end
      sig = intg + decimal_point + decimal_point_zeros + mantissa
      [sig, intg.length + mantissa.length, intg, decimal_point, decimal_point_zeros, mantissa]
    end

    # conform number to significant digits as string
    # @param [String] number to be conformed
    # @param [Integer] sig_digits (desired number of significant digits)
    # @return [String] number limited to specified significant digits
    def self.conform_significant(number, sig_digits)
      input = significant_digits(number.to_s)
      input_string = input[0]
      intg = input[2]
      decimal_point = input[3]
      decimal_position = input_string.index('.')
      decimal_point_zeros = input[4]   # decimal_point_zeros length > 0 implies mantissa only case
      mantissa = input[5]     # mantissa complete iff no decimal_point_zeros
      digit_string = intg + decimal_point_zeros + mantissa
      reduction = input[1] - sig_digits
      result = digit_string   # failsafe result
      if reduction > 0    # need to reduce significant digits
        result = ''
        for index in (0...sig_digits)       # collect ONLY significant digits
          digit = digit_string[index]   # if number is "0", digit is nil
          result += digit
          next
        end
        if digit_string.length > sig_digits     # clean up integer least significant digits
          if sig_digits > 0     # test degenerate case of 0 input
            if digit_string[index + 1].to_i >= 5
              result = (result.to_i + 1).to_s # round if necessary
            end
          end
          for ndex in (0...(intg.length - sig_digits))
            result += '0'
            next
          end
        end
      else        # no reduction or add digits
        for ndex in (0...(sig_digits - digit_string.length))
          result += '0'
          next
        end
      end
      unless decimal_position.nil?
        # this devolves to if decimal_position = 0, prepend "0."   OR
        # if decimal_position == end of string, don't add decimal_point
        # otherwise add decimal_point at decimal_position
        if result.length <= sig_digits
          if decimal_position == 0
            result.insert(decimal_position, '0' + decimal_point)  # make a valid Ruby number
          else
            if decimal_position < sig_digits
              result.insert(decimal_position, decimal_point)
            end
          end
        end
      end
      result
    end



    # @return [Hash]
    # coordinates from the label parsed to elements
    def self.coordinates_regex_from_verbatim_label(text)
      return nil if text.blank?
      text = text.gsub("''", '"')
          .gsub("´´", '"')
          .gsub("ʹʹ", '"')
          .gsub("ʼʼ", '"')
          .gsub("ˊˊ", '"')
          .squish
      text = ' ' + text + ' '

      coordinates = {}

      #  pattern: 42°5'18.1"S88°11'43.3"W
      if matchdata1 = text.match(/\D(\d+) ?[\*°ººod˚ ] ?(\d+) ?[ '´ʹ΄′ʼ’ˊ‘] ?(\d+[\.|,]\d+|\d+) ?[ "ʺ″”ˮ'´ʹ′΄ʼ’ˊ‘]['´ʹ′΄ʼ’ˊ‘]? ?([nN]|[sS])[\.,;]? ?(\d+) ?[\*°ººod˚ ] ?(\d+) ?[ '´ʹ′΄ʼ’ˊ‘]\ ?(\d+[\.|,]\d+|\d+) ?[ "ʺ″”ˮ'´ʹ′΄ʼ’ˊ‘]['´ʹ′΄ʼ’ˊ‘]? ?([wW]|[eE])\W/)
        coordinates[:lat_deg] = matchdata1[1]
        coordinates[:lat_min] = matchdata1[2]
        coordinates[:lat_sec] = matchdata1[3]
        coordinates[:lat_ns]  = matchdata1[4]
        coordinates[:long_deg] = matchdata1[5]
        coordinates[:long_min] = matchdata1[6]
        coordinates[:long_sec] = matchdata1[7]
        coordinates[:long_we]  = matchdata1[8]
        # pattern: S42°5'18.1"W88°11'43.3"
      elsif matchdata2 = text.match(/\W([nN]|[sS])\.? ?(\d+) ?[\*°ººod˚ ] ?(\d+) ?[ '´ʹ′΄ʼ’ˊ‘] ?(\d+[\.|,]\d+|\d+) ?[ "ʺ″”ˮ'´ʹ′΄ʼ’ˊ‘]['´ʹ′΄ʼ’ˊ‘]?[\.,;]? ?([wW]|[eE])\.? ?(\d+) ?[\*°ººod˚ ] ?(\d+) ?[ '´ʹ′΄ʼ’ˊ‘] ?(\d+[\.|,]\d+|\d+) ?[ "ʺ″”ˮ'´ʹ′΄ʼ’ˊ‘]?['´ʹ′΄ʼ’ˊ‘]?\D/)
        coordinates[:lat_deg] = matchdata2[2]
        coordinates[:lat_min] = matchdata2[3]
        coordinates[:lat_sec] = matchdata2[4]
        coordinates[:lat_ns]  = matchdata2[1]
        coordinates[:long_deg] = matchdata2[6]
        coordinates[:long_min] = matchdata2[7]
        coordinates[:long_sec] = matchdata2[8]
        coordinates[:long_we]  = matchdata2[5]
        # pattern: S42°5.18'W88°11.43'
      elsif matchdata3 = text.match(/\W([nN]|[sS])\.? ?(\d+) ?[\*°ººod˚ ] ?(\d+[\.|,]\d+|\d+) ?[ '´ʹ′΄ʼ’ˊ‘][\.,;]? ?([wW]|[eE])\.? ?(\d+) ?[\*°ººod˚ ] ?(\d+[\.|,]\d+|\d+) ?[ '´ʹ′΄ʼ’ˊ‘]?\D/)
        coordinates[:lat_deg] = matchdata3[2]
        coordinates[:lat_min] = matchdata3[3]
        coordinates[:lat_ns]  = matchdata3[1]
        coordinates[:long_deg] = matchdata3[5]
        coordinates[:long_min] = matchdata3[6]
        coordinates[:long_we]  = matchdata3[4]
        # pattern: 42°5.18'S88°11.43'W
      elsif matchdata4 = text.match(/\D(\d+) ?[\*°ººod˚ ] ?(\d+[\.|,]\d+|\d+) ?[ '´ʹ′΄ʼ’ˊ‘]? ?([nN]|[sS])[\.,;]? ?(\d+) ?[\*°ººod˚ ] ?(\d+[\.|,]\d+|\d+) ?[ '´ʹ′΄ʼ’ˊ‘]? ?([wW]|[eE])\W/)
        coordinates[:lat_deg] = matchdata4[1]
        coordinates[:lat_min] = matchdata4[2]
        coordinates[:lat_ns]  = matchdata4[3]
        coordinates[:long_deg] = matchdata4[4]
        coordinates[:long_min] = matchdata4[5]
        coordinates[:long_we]  = matchdata4[6]
        # pattern: 42.18°S88.43°W
      elsif matchdata6 = text.match(/\D(\d+[\.|,]\d+|\d+) ?[\*°ººod˚ ] ?([nN]|[sS])[\.,;]? ?(\d+[\.|,]\d+|\d+) ?[\*°ººod˚ ] ?([wW]|[eE])\W/)
        coordinates[:lat_deg] = matchdata6[1]
        coordinates[:lat_ns]  = matchdata6[2]
        coordinates[:long_deg] = matchdata6[3]
        coordinates[:long_we]  = matchdata6[4]
        # pattern: S42.18°W88.34°
      elsif matchdata5 = text.match(/\W([nN]|[sS])\.? ?(\d+[\.|,]\d+|\d+) ?[\*°ººod˚ ][\.,;]? ?([wW]|[eE])\.? ?(\d+[\.|,]\d+|\d+) ?[\*°ººod˚ ]?\D/)
        coordinates[:lat_deg] = matchdata5[2]
        coordinates[:lat_ns]  = matchdata5[1]
        coordinates[:long_deg] = matchdata5[4]
        coordinates[:long_we]  = matchdata5[3]
        # pattern: -12.263, 49.398
      elsif matchdata7 = text.match(/\D(-?\d+[\.|,]\d+|\-?\d+),.*?(-?\d+[\.|,]\d+|\-?\d+)\D/)
        coordinates[:lat_deg] = matchdata7[1]
        coordinates[:long_deg] = matchdata7[2]
      end
      coordinates[:lat_deg] = coordinates[:lat_deg].gsub(',', '.') if coordinates[:lat_deg]
      coordinates[:lat_min] = coordinates[:lat_min].gsub(',', '.') if coordinates[:lat_min]
      coordinates[:lat_sec] = coordinates[:lat_sec].gsub(',', '.') if coordinates[:lat_sec]
      coordinates[:lat_ns] = coordinates[:lat_ns].capitalize if coordinates[:lat_ns]
      coordinates[:long_deg] = coordinates[:long_deg].gsub(',', '.') if coordinates[:long_deg]
      coordinates[:long_min] = coordinates[:long_min].gsub(',', '.') if coordinates[:long_min]
      coordinates[:long_sec] = coordinates[:long_sec].gsub(',', '.') if coordinates[:long_sec]
      coordinates[:lat_we] = coordinates[:lat_we].capitalize if coordinates[:lat_we]

      return {} if !coordinates[:lat_deg] || !coordinates[:long_deg]
      return {} if coordinates[:lat_deg].to_f > 90 || coordinates[:lat_deg].to_f < -90
      return {} if coordinates[:lat_min].to_f >= 60
      return {} if coordinates[:lat_sec].to_f >= 60
      return {} if coordinates[:long_deg].to_f > 180 || coordinates[:long_deg].to_f < -180
      return {} if coordinates[:long_min].to_f >= 60
      return {} if coordinates[:long_sec].to_f >= 60


      if coordinates[:lat_ns].nil?
        lat_string = coordinates[:lat_deg]
        if coordinates[:lat_deg].to_f < 0 # -5° S; 5° N
          coordinates[:lat_ns] = 'S'
          coordinates[:lat_deg] = coordinates[:lat_deg].gsub('-', '')
        else
          coordinates[:lat_ns] = 'N' # -5° W; 5° E
        end
      else
        lat_string = coordinates[:lat_deg] + '°'
        lat_string += coordinates[:lat_min] + "'" if coordinates[:lat_min]
        lat_string += coordinates[:lat_sec] + '"' if coordinates[:lat_sec]
        lat_string += coordinates[:lat_ns]
      end
      if coordinates[:long_we].nil?
        long_string = coordinates[:long_deg]
        if coordinates[:long_deg].to_f < 0
          coordinates[:long_we] = 'W'
          coordinates[:long_deg] = coordinates[:long_deg].gsub('-', '')
        else
          coordinates[:long_we] = 'E'
        end
      else
        long_string = coordinates[:long_deg] + '°'
        long_string += coordinates[:long_min] + "'" if coordinates[:long_min]
        long_string += coordinates[:long_sec] + '"' if coordinates[:long_sec]
        long_string += coordinates[:long_we]
      end

      lat_dec = (coordinates[:lat_deg].to_f + (coordinates[:lat_min].to_f / 60) + (coordinates[:lat_sec].to_f / 3600)).round(6).to_s
      lat_dec = '-' + lat_dec if coordinates[:lat_ns] == 'S'
      long_dec = (coordinates[:long_deg].to_f + (coordinates[:long_min].to_f / 60) + (coordinates[:long_sec].to_f / 3600)).round(6).to_s
      long_dec = '-' + long_dec if coordinates[:long_we] == 'W'

      c = {
          verbatim: {verbatim_latitude: lat_string, verbatim_longitude: long_string},
          decimal: {decimal_latitude: lat_dec, decimal_longitude: long_dec},
          parsed: coordinates
      }
      return c
    end

  end
end
