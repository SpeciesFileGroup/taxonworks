module SoftValidation

  # A SoftValidations instance contains a set of SoftValidations
  # and some code that tracks whether those validations have
  # been run and fixed.
  #
  # @!attribute soft_validations
  #   @return [Array]
  #   the set of SoftValidations (i.e. problems with a record/instance)
  # @!attribute instance
  #   the object being validated, an instance of an ActiveRecord model
  # @!attribute validated
  #   @return [Boolean]
  #   True if the soft validations methods have been called.
  # @!attribute fixed
  #   @return [Symbol]
  #   True if fix() has been called. Note that this does not imply that all SoftValidations have been fixed!
  class SoftValidations
    attr_accessor :soft_validations, :instance, :validated, :fixes_run

    # @param[ActiveRecord] a instance of some ActiveRecord model
    def initialize(instance)
      @validated = false
      @fixes_run = false
      @instance = instance # Klass from here
      @soft_validations = []
    end

    # Add a soft validation to a data instance.
    # 
    # @param attribute [Symbol]
    #   a column attribute or :base
    # @param message [String]
    #   a message describing the soft validation to the user, i.e. what has gone wrong
    def add(attribute, message, options = {})
      # Must be left here
      method = caller[0][/`(block\ in\ )*([^']*)'/, 2].to_sym # janky, the caller of this method, that is the method referenced in `soft_validate()`, used to get the fix for this Instance added

      raise SoftValidationError, "can not add soft validation to [#{attribute}] - not a column name or 'base'" if !(['base'] + instance.class.column_names).include?(attribute.to_s)
      raise SoftValidationError, 'no :attribute or message provided to soft validation' if attribute.nil? || message.nil? || message.length == 0

      options.merge!(
        soft_validation_method: method,
        attribute: attribute,
        message: message,
        resolution: resolution_for(method),
        fix: fix_for(method)
      )

      sv = ::SoftValidation::SoftValidation.new(options)

      @soft_validations << sv
    end

    # @return [Boolean]
    #   soft validations have been run
    def validated?
      @validated
    end

    # @param [Symbol, String] method
    # @return [Array]
    def resolution_for(method)
      return [] if method.nil?
      self.instance.class.soft_validation_methods[method].resolution
    end

    # @param [Symbol, String] method
    # @return [Array]
    def fix_for(method)
      return [] if method.nil?
      self.instance.class.soft_validation_methods[method].fix
    end

    # @return [Boolean]
    #   fixes on resultant soft validations have been run
    def fixes_run?
      @fixes_run
    end

    # @return [Boolean]
    #   soft validations run and none were generated
    def complete?
      validated? && soft_validations.count == 0
    end

    # @return [Hash<attribute><Array>]
    #   a hash listing the results of the fixes
    def fix_messages
      messages = {}
      if fixes_run?
        soft_validations.each do |v|
          messages[v.attribute] ||= []
          messages[v.attribute].push << v.result_message
        end
      end
      messages
    end

    # @param [Symbol] attribute
    # @return [Array]
    def on(attribute)
      soft_validations.select{|v| v.attribute == attribute}
    end

    # @return [Array]
    def messages
      soft_validations.collect{ |v| v.message}
    end

    # @param [Symbol] attribute
    # @return [Array]
    def messages_on(attribute)
      on(attribute).collect{|v| v.message}
    end

    def size
      soft_validations.size
    end
  end

end
