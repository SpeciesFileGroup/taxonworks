module SoftValidation

  # A metadata structure for each soft validation
  class SoftValidationMethod

    # @param [Symbol]
    # the soft validation method
    attr_accessor :method

    # @param [Symbol]
    # the (base) klass that has method
    attr_accessor :klass

    # @return [String, nil]
    #  human name/title of this soft validation
    attr_accessor :name

    # @return [String, nil]
    # human description of this soft validation
    attr_accessor :description

    # @return [Array, nil]
    # of symbols
    attr_accessor :resolution

    # @return [Symbol, nil]
    #  assign this soft validation method to a set
    attr_accessor :set

    # @return [Symbol, nil]
    #  the name of the method that will fix this issue 
    attr_accessor :fix

    # @return [Boolean]
    #   flagged methods are not executed by default
    attr_accessor :flagged

    # @param [Hash] args
    def initialize(options)
      raise(SoftValidationError, 'missing method and klass') if options[:method].nil? || options[:klass].nil?
      options.each do |k,v|
        send("#{k}=", v)
      end
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
    def fixable?
      @fix.kind_of?(Symbol)
    end

    # @return [Boolean]
    def flagged? 
      @flagged == true
    end

    # @return[String]
    #   a human readable string describing the general point of this soft validation method
    def to_s
      [(name.blank? ? "#{method} (temporary name)" : name), (description.blank? ? '(no description provided)' : description)].join(': ')
    end

    private

    # @return Boolean
    #   true - the soft validation method should be retained
    #   false - the soft validation method does not match, it will be excluded from soft_validate()
    # @param is_fixable [Boolean, nil] 
    #   nil, false - don't require method be fixable to pass
    #   true - require method to be fixable to pass
    # @param is_flagged [Boolean] 
    #    true - allow all
    #    false - allow only if not flagged 
    def matches?(is_fixable, include_flagged = false)
      a = is_fixable.nil? ? true : (is_fixable ? fixable? : true)
      b = include_flagged == true ? true : !flagged
      a && b
    end
    
  end

end

