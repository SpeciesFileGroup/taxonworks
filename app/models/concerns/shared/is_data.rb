# Shared code for a classes that are "data" sensu TaxonWorks (things like Projects, users, and preferences are not data).
#
# !! This module must in included last !!
#
module Shared::IsData

  extend ActiveSupport::Concern

  included do
    include Pinnable
    include Levenshtein
    include Annotation
    include Scopes
  end

  module ClassMethods

    # @return [Boolean]
    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

    # @return [Boolean]
    #   use update vs. a set of ids, but require the update to pass for all or none
    def batch_update_attribute(ids: [], attribute: nil, value: nil)
      return false if ids.empty? || attribute.nil? || value.nil?
      begin
        self.transaction do
          self.where(id: ids).find_each do |li|
            li.update(attribute => value)
          end
        end
      rescue
        return false
      end
      true
    end

=begin
---------------------------
             1   2   3   4       s returned for similar
---------------------------
1    |abc |  C   s   si  s       i returned for identical
---------------------------
2    |abcd|  s   C   s   s       C returned if class method, identical or similar
---------------------------
3    |abc |  si  s   C   s
---------------------------
4    | bc |              C
---------------------------
=end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def similar(attr)
      klass = self
      attr  = Stripper.strip_similar_attributes(klass, attr)
      attr  = attr.select { |_kee, val| val.present? }

      scope = klass.where(attr)
      scope
    end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def identical(attr)
      klass = self
      attr  = Stripper.strip_identical_attributes(klass, attr)

      scope = klass.where(attr)
      scope
    end
  end

  # @return [Object]
  #   the same object, but namespaced to the base class
  #   used many places, might be good target for optimization
  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end

  # @return [Boolean]
  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  # @return [Boolean]
  def is_in_use?
    self.class.reflect_on_all_associations(:has_many).each do |r|
      return true if self.send(r.name).count > 0
    end

    self.class.reflect_on_all_associations(:has_one).each do |r|
      return true if self.send(r.name).count > 0
    end

    false
  end

  # @param [Symbol] keys
  # @return [Hash]
  def errors_excepting(*keys)
    valid?
    keys.each do |k|
      errors.delete(k)
    end
    errors
  end

  # @return [Scope]
  def similar
    klass = self.class
    attr  = Stripper.strip_similar_attributes(klass, attributes)
    # matching only those attributes from the instance which are not empty
    attr = attr.select{ |_kee, val| val.present? }
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # @return [Scope]
  def identical
    klass = self.class
    attr  = Stripper.strip_identical_attributes(klass, attributes)
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # @param [Symbol] keys
  # @return [Array]
  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

  module Stripper
    # protected

    # @param [Hash] attr is hash
    # @return [Hash]
    def self.strip_similar_attributes(klass, attr = {})
      begin # test to see if this class has an IGNORE_SIMILAR constant
        ig = add_class_list(klass::IGNORE_SIMILAR)
      rescue NameError
        ig = RESERVED_ATTRIBUTES.dup.map(&:to_s)
      end
      attr.delete_if{|kee, _value| ig.include?(kee) }
      attr
    end

    # @param [Hash] attr is hash
    # @return [Hash]
    def self.strip_identical_attributes(klass, attr = {})
      begin # test to see if this class has an IGNORE_IDENTICAL constant
        ig = add_class_list(klass::IGNORE_IDENTICAL)
      rescue NameError
        ig = RESERVED_ATTRIBUTES.dup.map(&:to_s)
      end
      attr.delete_if{ |kee, _value| ig.include?(kee) }
      attr
    end

    # @param [Array] list of symbols to be ignored
    # @return [Array] of strings to be ignored
    def self.add_class_list(list)
      ig_list  = RESERVED_ATTRIBUTES.dup
      add_list = list.dup if list.any?
      ig_list  += add_list if add_list
      # convert ignore list from symbols to strings for subsequent include test
      return ig_list.map(&:to_s)
    end

    # @param [Class] klass
    # @param [Symbol, String] compare - one of [:identical, :similar] (optional, defaults to :identical)
    # @return [Array] of symbols which represent the attributes which will be tested for a given class
    def self.tested_attributes(klass, compare = :identical)
      case compare.to_s
        when 'similar'
          obj = klass.new
          obj.attributes.each_key { |kee| obj[kee] = 1 }
          strip_similar_attributes(klass, obj.attributes).collect { |kee, _val| kee.to_sym }
        # when 'identical'
        #   strip_identical_attributes(klass, klass.new.attributes).collect { |kee, _val| kee.to_sym }
        else
          strip_identical_attributes(klass, klass.new.attributes).collect { |kee, _val| kee.to_sym }
      end
    end
  end
end


