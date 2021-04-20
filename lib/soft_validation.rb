# TODO: REMOVE
require 'byebug'
require 'amazing_print'

require_relative 'soft_validation/soft_validation'
require_relative 'soft_validation/soft_validations'
require_relative 'soft_validation/soft_validation_method'
require_relative 'utilities/params'
require "active_support/all"

# Vaguely inspired by concepts from by svn://rubyforge.org/var/svn/softvalidations, but not as elegant.
#
# Soft validations are a means to tie warnings or suggestions to instances of data.
# Soft validations do not prevent an instance from being saved.  They are not intended
# to be bound to AR callbacks, but this may be possible ultimately. They may be used to
# alert the user to data issues that need to be addressed, or alert the programmer
# who is batch parsing data as to the quality of the incoming data, etc..
#
# There are 2 stages to defining a soft validation. First index and provide an option general description
# of the soft validation itself using the `soft_validate` macro in the class.  Second, add the method (logic)
# that is called, and a set of message that the user will see when the logic passes or fails.  To state in another way:
#
# * The name and description (intent) of the soft validation is optionally provided with the macro setting the soft validation (`Klass.soft_validate()`.
# * The human messages ('there is a problem here!', 'the problem is fixed', 'we tried to fix, but failed!') are defined with the method logic itself.  This is intentionally done to
# keep the intent of the logic close to the consequences of the logic.
#
# Devloper tips:
# 
# - Protonym.soft_validation( ) <- all technical metadata and a gross description (the intent), optionally, goes here
# - @protonym.sv_xyz( ) <- all human guidance (warning, outcomes) goes here, including the attribute to point to in the UI
# - *fix* method names should not be exposed to the UI
#
#
# Usage:
#
#   class Foo < ApplicationRecord
#     include SoftValidation
#     soft_validate(:a_soft_validation_method, fix: :cook_cheezburgers)
#
#     # Validations can be assigned to a set (only one), and validations in a set
#     # can be called individually.
#     soft_validate(:other_soft_validation_method, set: :some_set)
#     soft_validate(:yet_another_method, set: :some_other_set )
#     soft_validate(:described_method, name: 'the validation for X', description: 'this validation does Z')
#     soft_validate(:a_third_method, resolution: [:route_name, route_name2])
#
#     soft_validate(:a_fourth_example, fix: :fix_method) # the detected issue can be fully resolved by calling this instance method
#
#     $hungry = true # demo only, don't use $globals
#
#     def a_soft_validation_method
#       soft_validations.add(:base, 'hungry!',                          # :base or a model attribute (column)
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
#   f.soft_validate(only_sets: [:default])           # only run this set, the set of soft validations not assigned to a set
#   f.soft_validate(only_sets: [:some_other_set])    # only run these sets of validations
#   f.soft_validate(except_set: [:some_other_set])   # run non-flagged except soft validations in these sets
#   f.soft_validate(only_methods: :some_method)      # run only this soft validation (all other params ignored)
#   f.soft_validate(except_methods: [:some_method])  # run result except these soft validation methods
#   f.soft_validate(fixable: true)                   # run all soft validations that have a fix
#   f.soft_validate(fixable: false)                  # run all soft validations without a fix
#   f.soft_validate(flagged: true)                   # run all, *including* methods flagged by developers as "a-typical", there is no flagged: false, as it is default)
#
module SoftValidation

  class SoftValidationError < StandardError; end

  # An index of the soft validators in superclasses
  ANCESTORS_WITH_SOFT_VALIDATIONS =
    Hash.new do |h, klass|
      h[klass.name] = (klass.ancestors.select {|a| a.respond_to?(:soft_validates?) && a.soft_validates?} - [klass]) # a < ApplicationRecord && would be faster but requires AR in spec
    end

  extend ActiveSupport::Concern

  included do
    attr_accessor :soft_validation_result

    # @return [Hash]
    #   An index of soft validation methods, keys are all methods
    #    `{ method_name: @method_instance, ... }`
    class_attribute :soft_validation_methods, default: {} # http://api.rubyonrails.org/classes/Class.html

    # @return [Hash]
    #   An index of soft validation methods by ClassName by set
    #   ' { ClassName' => { set: [ :method_name, ], ...}
    class_attribute :soft_validation_sets, default: { self.name =>  { default: []} }
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

    # @param method [Symbol]
    #   the name of the method with the soft validation logic, in TW like `sv_foo`
    # @param [Hash] options
    # @return [SoftValidationMethod]
    def add_method(method, options)
      # Yes, this has to be self.
      #
      # The critical insight is to use the `=` to access the setter method.  This allows the subclasses to have their own copy of `soft_validation_methods`
      # See https://api.rubyonrails.org/classes/Class.html
      # b
      self.soft_validation_methods = self.soft_validation_methods.merge(method =>  SoftValidationMethod.new(options))
    end

    # @param [Hash] method
    # @param [Hash] options
    def add_to_set(method, options)
      # TODO: update this to use setters?  Might not
      # be required because we are subgrouping by set.
      n = self.name
      set = options[:set]

      soft_validation_sets[n] ||= {}

      if set
        soft_validation_sets[n][set] ||= []
        soft_validation_sets[n][set] << method
      else
        soft_validation_sets[n][:default] ||= []
        soft_validation_sets[n][:default] << method
      end
    end

    # @return [Boolean] always true
    #   indicates that this class has included SoftValidation
    def soft_validates?
      true
    end

    # @return [Boolean]
    #   true if at least on soft_validate() exists in *this* class
    def has_self_soft_validations?
      soft_validation_methods_on_self.any?
    end

    # @return [Array]
    #   all methods from all sets from self (not superclasses)
    def soft_validation_methods_on_self
      a = soft_validation_sets[name]&.keys 
      return [] if a.nil?
      a.collect{|s| soft_validation_sets[name][s] }.flatten
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

    # @param only_sets [Array]
    #   names (symbols) of sets to run
    #
    # @param except_sets [Array]
    #   names (symbols]
    #
    # @param only_methods [Array]
    #   Names (symbols) of soft validation methods (not fix methods) to run. _If provided all other params are ignored._
    #
    # @param except_methods [Array]
    #   Names (symbols) of soft validation methods to exclude.  Ignored if only_methods is provided.
    #   
    # @param include_superclass [Boolean]
    #   include validations on superclasses, default is `true`
    #
    # @param include_flagged [Boolean]
    #   some soft validations have more consequences, these are flagged, default `false`
    #
    # @param fixable [Boolean]
    #   run soft validations only on fixable records, default is `false`
    #
    # @return [Array] of Symbol
    #   the names of the soft validation methods
    #
    #  An internal accessor for self.soft_validation_methods.  If nothing is provided all possible specs, excluding those flagged are returned.
    def soft_validators(only_sets: [], except_sets: [], only_methods: [], except_methods: [], include_flagged: false, fixable: nil, include_superclass: true)
      only_methods = Utilities::Params.arrayify(only_methods)
      return only_methods if !only_methods.empty?

      except_methods = Utilities::Params.arrayify(except_methods)

      # Get sets
      sets = get_sets(
        Utilities::Params.arrayify(only_sets),
        Utilities::Params.arrayify(except_sets)
      )

      methods = []
      klass_validators = []

      # Return "Local" (this class only) validators
      if has_self_soft_validations?

        a = []
        if sets.empty? && only_sets.empty? && except_sets.empty? # no sets provided, default to all methods
          a = self.soft_validation_methods.keys # self.soft_validation_method_names
        else
          sets.each do |s|
            a += self.soft_validation_sets[self.name][s]
          end
        end

        #  a.each do |b|
        #    byebug if self.soft_validation_methods[self.name][b].nil?
        #  end

        a.delete_if{|n| !self.soft_validation_methods[n].send(:matches?, fixable, include_flagged) }
        methods += a
      end

      # Add the rest of the validators, from Superclasses
      if include_superclass
        ancestor_klasses_with_validation.each do |klass|
          methods += klass.soft_validators(include_superclass: false, only_sets: only_sets, except_sets: except_sets, except_methods: except_methods, include_flagged: include_flagged, fixable: fixable)
        end
      end

      # Get rid of explicitly excluded
      methods.delete_if{|m| except_methods.include?(m) }

      methods
    end

    private

    def reset_soft_validation!
      self.soft_validation_methods = { }
      self.soft_validation_sets = { self.name => { default: []}}
    end

    def get_sets(only_sets = [], except_sets = [])
      all_sets = soft_validation_sets[name]&.keys
      return [] if all_sets.nil?
      a = (all_sets - except_sets)
      only_sets.empty? ? a : a & only_sets
    end

  end

  # Instance methods

  # @return [SoftValidations]
  def soft_validations
    @soft_validation_result ||= SoftValidations.new(self)
  end

  # @return [Nil]
  def clear_soft_validations
    @soft_validation_result = nil
  end

  # Run a set of soft validations.
  # * by default all validations except those with `flagged: true` are run
  # * when only|except_methods are set then these further restrict the scope of tests run
  # * except_methods will exclude methods from *any* result (i.e. sets are allowed)
  #
  # @param (see SoftValidation#soft_validators)
  #
  # @return [true]
  def soft_validate(**options)
    clear_soft_validations
    soft_validations

    soft_validators(**options).each do |sv_method|
      self.send(sv_method)
    end

    soft_validations.validated = true
    true
  end

  # @see Class.soft_validators
  def soft_validators(**options)
    self.class.soft_validators(**options)
  end

  # The validation set to fix is set prior to running the fix, at the first step.
  # It can be refined/restricted there as needed, letting specific contexts (e.g. 
  # access in controller) defined the scope.
  def fix_soft_validations
    return false if !soft_validated?
    soft_validations.soft_validations.each do |v|
      if fix = fix_for(v.soft_validation_method)
        if self.send(fix)
          v.fixed = :fixed
        else
          v.fixed = :fix_error
        end
      else
        v.fixed = :no_fix_available
      end
    end
    soft_validations.fixes_run = true
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

  # TODO: should be here?
  def fix_for(soft_validation_method)
    soft_validation_methods[soft_validation_method]&.fix
  end

end

# Original version was an AR extension, might revert to this at some point.
# class ApplicationRecord
#   include SoftValidation
# end
