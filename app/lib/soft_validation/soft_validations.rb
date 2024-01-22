module SoftValidation

  # A SoftValidations instance contains a set of SoftValidation(s).
  # It tracks whether the validations (set) have been run and fixed.
  class SoftValidations

    # @!attribute soft_validations
    #   @return [Array]
    #   the set of SoftValidations (i.e. problems with a record/instance)
    attr_accessor :soft_validations

    # @!attribute validated
    #   @return [Boolean]
    #   True if the soft validations methods have been called.
    attr_accessor :validated
    
    attr_accessor :fixes_run

    # @!attribute instance
    #   the object being validated, an instance of an ActiveRecord model
    attr_writer :instance

    # @param[ActiveRecord] a instance of some ActiveRecord model
    def initialize(instance)
      @validated = false
      @fixes_run = false
      @instance = instance # Klass from here <- stupid
      @soft_validations = []
    end

    # Add a soft validation to a data instance.
    # 
    # @param attribute [Symbol]
    #   a column attribute or :base
    # @param message [String]
    #   a message describing the soft validation to the user, i.e. what has gone wrong
    # @param options [Hash]
    #   legal keys are :failure_message and :success_message
    def add(attribute, message, options = {})
      # this is impossible to test.
      method = caller[0][/`(block\ in\ )*([^']*)'/, 2].to_sym # janky, the caller of this method, that is the method referenced in `soft_validate()`, used to get the fix for this Instance added

      raise SoftValidationError, "can not add soft validation to [#{attribute}] - not a column name or 'base'" if !(['base'] + @instance.class.column_names).include?(attribute.to_s)
      raise SoftValidationError, 'no :attribute or message provided to soft validation' if attribute.nil? || message.nil? || message.length == 0

      options.merge!(
        method_instance: @instance.class.soft_validation_methods[method], # inspected to expose method values
        attribute: attribute,
        message: message,
      )

      sv = ::SoftValidation::SoftValidation.new(options)

      @soft_validations << sv
    end

    # @return [Boolean]
    #   soft validations have been run
    def validated?
      @validated
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
