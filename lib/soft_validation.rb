# Vaguely inspired by concepts from by svn://rubyforge.org/var/svn/softvalidations, but not as elegant.
#
# Soft validations are a means to tie warnings or suggestions to instances of data.
# Soft validations do not prevent an instance from being saved.  They are not intended
# to be bound to AR callbacks, but this may be possible.  They may be used to 
# alert the user to data issues that need to be addressed, or alert the programmer
# who is batch parsing data as to the quality of the incoming data, etc..
#
# For example, soft validations could be shown on #show controller methods.
#
# Usage:
#
#   class Foo < ActiveRecord::Base
#     include SoftValidation
#     soft_validate(:a_soft_validation_method )
#
#     # Validations can be assigned to a set (only one), and validations in a set
#     # can be called individually.
#     soft_validate(:other_soft_validation_method, set: :some_set)
#     soft_validate(:yet_another_method, set: :some_other_set )
#  
#     $hungry = true 
# 
#     def a_soft_validation_method
#       soft_validations.add(:base, 'hungry!',                          # :base or a model attribute (column)
#         fix: :cook_cheezburgers,
#         success_message: 'no longer hungry, cooked a cheezeburger',
#         failure_message: 'oh no, cat ate your cheezeburger' 
#       ) if $hungry 
#     end
#     
#     def cook_cheezburgers
#       $hungry = false
#     end
#   end
#
#   f = Foo.new
#
#   f.soft_validations.validated?             # => false
#   f.soft_validations.fixes_run?             # => false
#   f.soft_validations.fixed?                 # => false 
#   f.soft_validations.complete?              # => false
#
#   f.soft_validate                           # => true 
#   f.soft_validated?                         # => true
#   f.soft_fixed?                             # => false   
#   f.soft_valid?                             # => false  # true if there are no SoftValidations produced
#
#   f.soft_validations.soft_validations                        # => [soft_validation, soft_validation1 ... ] 
#   f.soft_validations.soft_validations.size                   # => 1
#   f.soft_validations.soft_validations.first                  # => A SoftValidation instance
#
#   # SoftValidation attributes
#   f.soft_validations.soft_validations.first.attribute          # => :base 
#   f.soft_validations.soft_validations.first.message            # => 'hungry!'
#   f.soft_validations.soft_validations.first.success_message    # => 'no longer hungry, cooked a cheezeburger'
#   f.soft_validations.soft_validations.first.failure_message    # => 'oh no, cat ate your cheezeburger' 
#
#   f.soft_validations.soft_validations.first.fixed?           # => false
#   f.soft_validations.soft_validations.first.result_message     # => 'fix not yet run'
#   
#   f.fix_soft_validations                    # => true
#   f.soft_fixed?                             # => true
#   f.soft_valid?                             # => false !! There is still a SoftValidation generated, will be true next time it's run
#
#   f.soft_validations.fixes_run                               # => true
#   f.soft_validations.soft_validations.first.fixed?           # => true
#   f.soft_validations.soft_validations.first.result_message   # => 'no longer hungry, cooked a cheezeburger'
#   f.soft_validations.on(:base)               # => [soft_validation, ... ] 
#   f.soft_validations.messages                # => ['hungry!'] 
#   f.soft_validations.messages_on(:base)      # => ['hungry!'] 
#
#   f.clear_soft_validations  
#  
#   f.soft_validate(:some_other_set)          # only run this set of validations
#
module SoftValidation

  # A SoftValidations instance contains a set of SoftValidations
  # and some code that tracks whether those validations have
  # been fixed, etc.
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
      @instance = instance
      @soft_validations = []
    end

    # @param [Symbol] attribute a column attribute or :base
    # @param [String] message a message describing the soft validation to the user, i.e. what has gone wrong
    # @param [Hash{fix: :method_name, success_message: String, failure_message: String }] options the method identified by :fix should fully resolve the SoftValidation. 
    def add(attribute, message, options = {})
      # TODO: Stub a generic TW Error and raise it instead
      raise "can not add soft validation to [#{attribute}] - not a column name or 'base'" if !(['base'] + @instance.class.column_names).include?(attribute.to_s)
      raise "invalid :fix_trigger" if !options[:fix_trigger].blank? && ![:all, :automatic, :requested].include?(options[:fix_trigger])
      return false if attribute.nil? || message.nil? || message.length == 0
      return false if (options[:success_message] || options[:failure_message]) && !options[:fix]
      sv = SoftValidation.new
      sv.attribute = attribute 
      sv.message = message
      sv.fix = options[:fix]
      sv.fix_trigger = options[:fix_trigger]
      sv.fix_trigger ||= :automatic
      sv.success_message = options[:success_message] 
      sv.failure_message = options[:failure_message] 
      @soft_validations << sv
    end

 #  def soft_validations(scope = :all)
 #    set = ( scope == :all ? [:automatic, :requested] : [scope] )
 #    @soft_validations.select{|v| set.include?(v.fix_trigger)}
 #  end

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
      validated? && @soft_validations.count == 0 
    end

    # @return [Hash<attribute><Array>]
    #   a hash listing the results of the fixes 
    def fix_messages
      messages = {}
      if fixes_run?
        @soft_validations.each do |v| 
          messages[v.attribute] ||= []
          messages[v.attribute] << (v.result_message) 
        end
      end
      messages
    end

    def on(attribute)
      @soft_validations.select{|v| v.attribute == attribute} 
    end

    def messages
      @soft_validations.collect{ |v| v.message}
    end

    def messages_on(attribute)
      on(attribute).collect{|v| v.message}
    end
  end


  # A SoftValidation is identifies an individual issue with the instance 
  # it has been run against. It is generated by a soft_validation_method.
  #
  #
  # @!attribute attribute 
  #   @return [Symbol]
  #     the attribute (column name), or :base to which the soft validation is tied
  # @!attribute message
  #   @return [String]
  #     Required.  A short message describing the soft validation
  # @!attribute fix 
  #   @return [Symbol]
  #     Optional. Identifies a method that fixes the soft validation in question.  I.e. the method 
  #     when run should eliminate subsequent identical soft validation warnings from being generated.
  #     Fix methods should return true or false. 
  # @!attribute fix_trigger
  #   @return [Symbol]
  #     Optional when :fix is provided. Must be one of :automatic or :requested.  Defaults to :automatic
  # @!attribute success_message
  #   @return [String]
  #     Optional.  Requires a fix method.  A short message describing the message provided when the soft validation was successfully fixed. 
  # @!attribute failure_message
  #   @return [String]
  #     Optional.  Requires a fix method.  A short message describing the message provided when the soft validation was NOT successfully fixed. 
  # @!attribute fixed 
  #   @return [Symbol]
  #     Stores a state with one of 
  #     :fixed                  (fixes run and SoftValidation was fixed), 
  #     :fix_error              (fixes run and SoftValidation fix failed), 
  #     :fix_not_triggered      (fixes run, and SoftValidation was not triggered because of scope)
  #     :fix_not_yet_run        (there is a fix method available, but it hasn't been run)
  #     :no_fix_available       (no fix method was provided)
  class SoftValidation
    attr_accessor :attribute, :message, :fix, :fix_trigger, :success_message, :failure_message, :fixed

    def initialize
      @fixed = :fix_not_yet_run
    end

    def fixed?
      return true if @fixed == :fixed
      false
    end

    def result_message
      case fixed
      when :fix_not_triggered
        'fix available, but not triggered'
      when :no_fix_available
        'fix not run, no fix available'
      when :fix_not_yet_run
        'fix not yet run'
      when :fixed 
        self.success_message.nil? ? "'#{message}' was fixed (no result message provided)" : self.success_message
      when :fix_error 
        self.failure_message.nil? ? "'#{message}' was NOT fixed (no result message provided)" : self.failure_message
      end
    end
  end

  extend ActiveSupport::Concern

  included do
    attr_accessor :soft_validation_result
    class_attribute :soft_validation_methods, instance_writer: false  # http://api.rubyonrails.org/classes/Class.html
    self.soft_validation_methods = {self.name => { all: [] }}
  end

  module ClassMethods
    def soft_validate(method, options = {})
      self.soft_validation_methods[self.name] ||= {}
      self.soft_validation_methods[self.name][:all] ||= [] 
      self.soft_validation_methods[self.name][:all] << method 
      if options[:set]
        self.soft_validation_methods[self.name][options[:set]] ||= []
        self.soft_validation_methods[self.name][options[:set]] << method 
      end
      true
    end

    def soft_validates?
      true
    end

    # an internal accessor for self.soft_validation_methods 
    # @return [Array of Symbol]
    #   the names of the soft validation methods 
    # @param [:set, Symbol]
    #   the set to return
    # @param [:ancestors, Boolean]
    #    whether to also return the ancestors validation methods 
    def soft_validators(set: :all, include_ancestors: true)
      methods = []
      klass_validators = self.soft_validation_methods[self.name][set]
      methods += klass_validators if !klass_validators.nil? 
      if include_ancestors
        ancestor_klasses_with_validation.each do |klass|
          methods += klass.soft_validators(set: set, include_ancestors: false)
        end
      end
      methods 
    end

    def ancestor_klasses_with_validation
      self.ancestors.select{|a| a.respond_to?(:soft_validates?) && a.soft_validates?} - [self]  # a < ActiveRecord::Base && would be faster but requires AR in spec
    end
  end

  # instance methods

  def soft_validations    
    @soft_validation_result ||= SoftValidations.new(self)    
  end

  def clear_soft_validations 
    @soft_validation_result = nil 
  end 

  # @return [True] 
  # @param [:set, Symbol]  set the set of soft validations to run
  # @param [:ancestors, Boolean] wether to also validate ancestors soft validations
  def soft_validate(set = :all, include_ancestors = true)
    clear_soft_validations
    soft_validations
    sets = case set.class.name
           when 'Array'
             set
           when 'Symbol'
             [set]
           when 'String'
             [set.to_sym]
           end

    sets.each do |s| 
      self.class.soft_validators(set: s, include_ancestors: include_ancestors).each do |m|
        self.send(m)
      end
    end
    soft_validations.validated = true
    true
  end

  def fix_soft_validations(scope = :automatic)
    return false if !soft_validated?
    raise 'invalid scope passed to fix_soft_validations' if ![:all, :automatic, :requested].include?(scope)
    soft_validations.soft_validations.each do |v|
      if v.fix 
        if v.fix_trigger == scope
          if self.send(v.fix) 
            v.fixed = :fixed 
          else
            v.fixed = :fix_error
          end
        else
          v.fixed = :fix_not_triggered
        end
      else
        v.fixed = :no_fix_available
      end
    end
    soft_validations.fixes_run = scope 
    true
  end

  def soft_validated?
    soft_validations.validated?
  end

  def soft_fixed?
    soft_validations.fixes_run?
  end 

  def soft_valid?
    soft_validations.complete?
  end

end

# Original version was an AR extension, might revert to this at some point.
# class ActiveRecord::Base
#   include SoftValidation
# end


