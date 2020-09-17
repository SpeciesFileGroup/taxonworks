# Utilities for comparing 
module Shared::IsData::Stripper

  extend ActiveSupport::Concern

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
