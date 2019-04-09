module SoftValidation

  # A metadata structure for each soft validation
  class SoftValidationMethod

    # @param[Symbol]
    # the soft validation method
    attr_accessor :method

    # @param[Symbol]
    # the (base) klass that has method
    attr_accessor :klass

    # @return[String, nil]
    #  human name/title of this soft validation
    attr_accessor :name

    # @return[String, nil]
    # human description of this soft validation
    attr_accessor :description

    # @return[Array, nil]
    # of symbols
    attr_accessor :resolution

    # @return[Symbol, nil]
    #  assign this soft validation method to a set
    attr_accessor :set

    # @return[Boolean]
    #   by default everything is fixable
    #      nil = fixable
    #      true = fixable (default value, not necessary option)
    #      false = not fixable
    #   manual assertion of whether the method has a fix
    #   !! This needs better reconcilition ultimately, as it is not coupled with sv_method inspection !!
    attr_accessor :has_fix

    # @param [Hash] args
    def initialize(options)
      raise(SoftValidationError, 'missing method and klass') if options[:method].nil? || options[:klass].nil?

      options.each do |k,v|
        send("#{k}=", v)
      end
      @has_fix = true if @has_fix.nil?
    end

    # @param [Array] v
    # @return [Array]
    def resolution=(v)
      raise(SoftValidationError, 'resolution: must be an Array') if v && v.class != Array
      @resolution = v
      @resolution ||= []
      @resolution
    end

    # @return [Array]
    def resolution
      @resolution || []
    end

    # @return[Boolean]
    #  a name and description provided
    def described?
      !name.blank? && !description.blank?
    end

    # @return[Boolean]
    #   whether there resolutions
    def resolutions?
      resolution.size > 0
    end

    # @return [Boolean]
    #   alias for has_fix 
    def fixable?
      has_fix
    end

    # @return[String]
    #   a human readable string describing the general point of this soft validation method
    def to_s
      [(name.blank? ? "#{method} (temporary name)" : name), (description.blank? ? '(no description provided)' : description)].join(': ')
    end
  end

end

