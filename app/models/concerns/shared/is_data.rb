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
    attr  = strip_similar_attributes(attributes)

    # 'none' until testing is finished
    scope = klass.not_self(self).none
    scope
  end

  # @return [Scope]
  def identical
    klass = self.class
    attr  = strip_identical_attributes(attributes)

    scope = klass.where(attr).not_self(self)
    scope
  end

  # @param [Symbol] keys
  # @return [Array]
  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

  protected

  # @param [Hash] attr is hash
  # @return [Hash]
  def strip_similar_attributes(attr = {})
    begin # test to see if thiss class has an IGNORE_SIMILAR constant
      ig = add_class_list(self.class::IGNORE_SIMILAR)
    rescue NameError
      ig = RESERVED_ATTRIBUTES.dup
    end
    attr.delete_if { |kee, value| ig.include?(kee) }
    attr
  end

  # @param [Hash] attr is hash
  # @return [Hash]
  def strip_identical_attributes(attr = {})
    begin # test to see if thiss class has an IGNORE_IDENTICAL constant
      ig = add_class_list(self.class::IGNORE_IDENTICAL)
    rescue NameError
      ig = RESERVED_ATTRIBUTES.dup
    end
    attr.delete_if { |kee, value| ig.include?(kee) }
    attr
  end

  # @param [Array] list of symbols to be ignored
  # @return [Array] of strings to be ignored
  def add_class_list(list)
    ig_list  = RESERVED_ATTRIBUTES.dup
    add_list = list.dup if list.any?
    ig_list  += add_list if add_list
    # convert ignore list from symbols to strings for subsequent include test
    return ig_list.map(&:to_s)
  end
end
