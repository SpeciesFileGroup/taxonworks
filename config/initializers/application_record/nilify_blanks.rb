#  See also /app/models/application_record.rb
#
#In theory this should work if we used the nulify_blanks gem. It does't.
#   ApplicationRecord.nilify_blanks
#
# via
#
# http://www.wenda.io/questions/60068/rails-force-empty-string-to-null-in-the-database.html
# https://github.com/rubiety/nilify_blanks/blob/master/lib/nilify_blanks.rb
module NilifyBlanks 
  extend ActiveSupport::Concern

  included do
    before_validation :nilify_blanks

    # You can add attributes to exclude from trimming 
    # by passing them to this variable
    class_attribute :attributes_to_not_trim
  end

  module ClassMethods
    # @param [Symbol, Array] attributes
    # @return [Symbol]
    def ignore_whitespace_on(*attributes) # this assigns the attributes to be trimmed
      raise('no attributes to trim') if attributes == #  (attributes.map(&:to_s) - self.column_names) != [] <- don't require AR connection
      self.attributes_to_not_trim = attributes.map(&:to_s)
    end


    protected

    # For testing purposes only!
    def reset_trimmable
      self.attributes_to_not_trim = [] 
    end
  end

  def nilify_blanks
    attributes.each do |column, value|
      next unless value.is_a?(String)
      next unless value.respond_to?(:blank?)
      if value.blank?
        write_attribute(column, nil) 
      else
        if trimmable?(column) && value =~ /\s/
          write_attribute(column, Utilities::Strings.nil_squish_strip(value))
        end
      end
    end
  end

  # @param attribute [String]
  def trimmable?(attribute)
    if self.attributes_to_not_trim # there are some
      return false if attributes_to_not_trim.include?(attribute) 
    end
    true
  end

end

# When we remove eager load from config/routes then this can come back in
# ApplicationRecord.send(:include, NilifyBlanks)
