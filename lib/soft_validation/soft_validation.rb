module SoftValidation

  # A SoftValidation is a instance of an actual issue. 
  # It strictly a message passing structure.
  #
  class SoftValidation
    # @return [Symbol, nil]
    #   The method name of the fix that can resolve this soft validation
    attr_writer :method_instance

    # @!attribute attribute
    #   @return [Symbol]
    #     the attribute (column name), or :base to which the soft validation is tied
    attr_accessor :attribute

    # @!attribute message
    #   @return [String]
    #     Required.  A short message describing the soft validation
    attr_accessor :message 

    # @!attribute success_message
    #   @return [String]
    #     Optional.  Requires a fix method.  A short message describing the message provided when the soft validation was successfully fixed.
    attr_accessor :success_message

    # @!attribute failure_message
    #   @return [String]
    #     Optional.  Requires a fix method.  A short message describing the message provided when the soft validation was NOT successfully fixed.
    attr_accessor :failure_message

    # @return [String, nil]
    #   Optional. A named route that points to where the issue can be resolved
    attr_reader :resolution

    # @return [Symbol, nil]
    #   Optional. The method name of the fix that can resolve this soft validation
    attr_reader :fix

    # @!attribute fixed
    #   @return [Symbol]
    #     Stores a state with one of
    #     :fixed                  (fixes run and SoftValidation was fixed),
    #     :fix_error              (fixes run and SoftValidation fix failed),
    #     :fix_not_triggered      (fixes run, and SoftValidation was not triggered because of scope)
    #     :fix_not_yet_run        (there is a fix method available, but it hasn't been run)
    #     :no_fix_available       (no fix method was provided)
    attr_accessor :fixed

    # @param [Hash] args
    def initialize(options = {})
      @fixed = :fix_not_yet_run
      options.each do |k,v|
        send("#{k}=", v)
      end
    end

    def description
      @method_instance.description
    end

    def fix 
      @method_instance.fix
    end

    def resolution 
      @method_instance.resolution
    end

    def soft_validation_method
      @method_instance.method
    end

    # @return [Boolean]
    def fixable?
      return true if !method_instance.fix.nil?
      false
    end

    # @return [Boolean]
    def fixed?
      return true if fixed == :fixed
      false
    end

    # @return [String]
    def result_message
      case fixed
      when :fix_not_triggered
        'fix available, but not triggered'
      when :no_fix_available
        'no fix available'
      when :fix_not_yet_run
        'fix not yet run'
      when :fixed
        success_message.nil? ? "'#{message}' was fixed (no result message provided)" : success_message
      when :fix_error
        failure_message.nil? ? "'#{message}' was NOT fixed (no result message provided)" : failure_message
      end
    end
  end
end

