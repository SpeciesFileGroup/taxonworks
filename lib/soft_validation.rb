# Vaguely inspired by concepts from by svn://rubyforge.org/var/svn/softvalidations.  
module SoftValidation

  class SoftValidations
    attr_accessor :soft_validations, :instance, :validated, :fixed

    def initialize(instance)
      @validated = false
      @fixed = false
      @instance = instance
      @soft_validations = []
    end

    def add(attribute, message, options = {})
      # TODO: Stub a generic TW Error and raise it instead
      raise "can not add soft validation to [#{attribute}] - not a column name or 'base'" if !(['base'] + @instance.class.column_names).include?(attribute.to_s)
      return false if attribute.nil? || message.nil? || message.length == 0
      return false if (options[:success_message] || options[:failure_message]) && !options[:fix]
      sv = SoftValidation.new
      sv.attribute = attribute 
      sv.message = message
      sv.fix = options[:fix]
      sv.success_message = options[:success_message] 
      sv.failure_message = options[:failure_message] 
      @soft_validations << sv
    end

    def validated?
      validated
    end

    def fixed?
      fixed
    end

    def complete?
      validated? && fixed? && self.soft_validations.count == 0 
    end

    # Fixes are all or nothing- re-run the fix set if you want to atomize, use atomized fix_set names to atomize
    # * Each fix should stand alone (simple) and can not be nested
    # * transactions!

    def fix_messages
      messages = {}
      if fixed
        soft_validations.each do |v| 
          messages[v.attribute] ||= []
          messages[v.attribute] << (v.success_message.nil? ? 'was fixed (no message provided)' : v.success_message )
        end
      end
      messages
    end
  end

  class SoftValidation
    attr_accessor :attribute, :message, :success_message, :failure_message, :fix
  end

  extend ActiveSupport::Concern
 
  included do
    attr_accessor :soft_validation_result
    class_attribute :soft_validation_methods, instance_writer: false  # http://api.rubyonrails.org/classes/Class.html
    self.soft_validation_methods = {all: []} 
  end

  module ClassMethods
    def soft_validate(method, options = {})
      self.soft_validation_methods[:all] << method 
      if options[:set]
        self.soft_validation_methods[options[:set]] ||= []
        self.soft_validation_methods[options[:set]] << method 
      end
      true
    end
  end

  # instance methods
  def soft_validations
    @soft_validation_result ||= SoftValidations.new(self)    
  end

  def clear_soft_validations 
    @soft_validation_result = nil 
  end 

  def soft_validate(set = :all)
    soft_validations
    sets = case set.class.name
    when 'Array'
      set
    when 'Symbol'
      [set]
    when 'String'
      [set.to_sym]
    end

    sets.each do |set| 
      self.class.soft_validation_methods[set].each do |s|
        self.send(s)
      end
    end
    soft_validations.validated = true
    true
  end

  def fix_soft_validations
    return false if !soft_validated?
    soft_validations.soft_validations.each do |v|
      self.send(v.fix) if v.fix
    end
    soft_validations.fixed = true
    true
  end

  # Convienence methods 
  def soft_validated?
    soft_validations.validated?
  end

  def soft_fixed?
    soft_validations.fixed?
  end 

  def soft_valid?
    soft_validations.complete?
  end

end

class ActiveRecord::Base
  include SoftValidation
end


