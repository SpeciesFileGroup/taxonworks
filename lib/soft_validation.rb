require 'soft_validation/soft_validation'
require 'soft_validation/soft_validations'
require 'soft_validation/soft_validation_method'

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
#   class Foo < ApplicationRecord
#     include SoftValidation
#     soft_validate(:a_soft_validation_method )
#
#     # Validations can be assigned to a set (only one), and validations in a set
#     # can be called individually.
#     soft_validate(:other_soft_validation_method, set: :some_set)
#     soft_validate(:yet_another_method, set: :some_other_set )
#     soft_validate(:a_third_method, resolution: [:route_name, route_name2]) # resolution is a pointer to route/interface that can resolve the problem !! NOT TESTED

#     soft_validate(:a_fourth_example, has_fix: false) # there are no fix methods assigned in :a_fourth_example 
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

  class SoftValidationError < StandardError; end

  ANCESTORS_WITH_SOFT_VALIDATIONS =
    Hash.new do |h, klass|
      h[klass.name] = (klass.ancestors.select {|a| a.respond_to?(:soft_validates?) && a.soft_validates?} - [klass]) # a < ApplicationRecord && would be faster but requires AR in spec
    end

  extend ActiveSupport::Concern

  included do
    attr_accessor :soft_validation_result

    class_attribute :soft_validation_methods, instance_writer: false  # http://api.rubyonrails.org/classes/Class.html
    self.soft_validation_methods = {self.name => {}}

    class_attribute :soft_validation_sets, instance_writer: false
    self.soft_validation_sets = { self.name =>  {all:  [] } }
  end

  module ClassMethods

    # @param [Symbol] method
    # @param [Hash] options
    # @return [Boolean]
    # self.name is the class name, e.g. Otu
    def soft_validate(method, options = {})
      options[:klass] = self
      options[:method] = method
      add_method(method, options)
      add_to_set(method, options)
      true
    end

    # @param [Symbol] method
    # @param [Hash] options
    # @return [SoftValidationMethod]
    def add_method(method, options)
      n = self.name
      self.soft_validation_methods[n] ||= {}
      self.soft_validation_methods[n][method] = SoftValidationMethod.new(options)
    end

    # @param [Hash] method
    # @param [Hash] options
    def add_to_set(method, options)
      n = self.name
      set = options[:set]

      self.soft_validation_sets[n] ||= {}

      self.soft_validation_sets[n][:all] ||= []
      self.soft_validation_sets[n][:all] << method

      if set
        self.soft_validation_sets[n][set] ||= []
        self.soft_validation_sets[n][set] << method
      end
    end

    # @return [Boolean] always true
    #   indicates that this class has included SoftValidation
    def soft_validates?
      true
    end

    # @return [Boolean]
    #    true if at least on soft_validate() exists in *this* class
    def has_self_soft_validations?
      self.soft_validation_sets[self.name] && self.soft_validation_sets[self.name][:all].count > 0
    end

    # an internal accessor for self.soft_validation_methods
    # @param [Symbol] set the set to return
    # @param [Boolean] ancestors whether to also return the ancestors validation methods
    # @return [Array] of Symbol
    #   the names of the soft validation methods
    def soft_validators(set: :all, include_ancestors: true, fixable_only: false)
      methods = []
     
      klass_validators = []

      
      
      if has_self_soft_validations?
        a = self.soft_validation_sets[self.name][set]
      
        if fixable_only
          a.each do |m|
            klass_validators.unshift(m) if self.soft_validation_methods[self.name][m].fixable? 
          end
        else
          klass_validators = a if a # self.soft_validation_sets[self.name][set] if has_self_soft_validations?
        end
      end

      methods += klass_validators # if !klass_validators.nil?

      if include_ancestors
        ancestor_klasses_with_validation.each do |klass|
          methods += klass.soft_validators(set: set, include_ancestors: false, fixable_only: fixable_only)
        end
      end
      methods
    end

    # @return [Hash]
    def soft_validation_descriptions
      result = {}
      soft_validators.each do |v|
        result[v]
      end
      result
    end

    # @return [Hash]
    def ancestor_klasses_with_validation
      ANCESTORS_WITH_SOFT_VALIDATIONS[self]
    end

    def reset_soft_validation!
      self.soft_validation_methods = {self.name => {}}
      self.soft_validation_sets = { self.name =>  {all:  [] } }
    end

  end

  # instance methods

  # @return [SoftValidations]
  def soft_validations
    @soft_validation_result ||= SoftValidations.new(self)
  end

  # @return [Nil]
  def clear_soft_validations
    @soft_validation_result = nil
  end

  # @param [Symbol] set the set of soft validations to run
  # @param [Boolean] ancestors whether to also validate ancestors soft validations
  # @return [Boolean] always true
  def soft_validate(set = :all, include_ancestors = true, only_fixable = false)
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
      self.class.soft_validators(set: s, include_ancestors: include_ancestors, fixable_only: only_fixable).each do |m|
        self.send(m)
      end
    end
    soft_validations.validated = true
    true
  end

  # @param [Symbol] scope
  # @return [Boolean]
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

  # @return [Boolean]
  def soft_validated?
    soft_validations.validated?
  end

  # @return [Boolean]
  def soft_fixed?
    soft_validations.fixes_run?
  end

  # @return [Boolean]
  def soft_valid?
    soft_validations.complete?
  end

end

# Original version was an AR extension, might revert to this at some point.
# class ApplicationRecord
#   include SoftValidation
# end
