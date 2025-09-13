#  See also /app/models/application_record.rb
#
# In theory this should work if we used the nulify_blanks gem. It does't.
#   ApplicationRecord.nilify_blanks
#
# via
#
# http://www.wenda.io/questions/60068/rails-force-empty-string-to-null-in-the-database.html
# https://github.com/rubiety/nilify_blanks/blob/master/lib/nilify_blanks.rb
#
# - Two stage:
#  - Strip invisibles (data clean) (all fields)
#  - "trim" whitespace  (can be excluded)
#    - Include a pre-processed step to convert  (only if not included in trim)
#
module NilifyBlanks
  extend ActiveSupport::Concern

  included do

    # We use a single method to handle two somewhat independant steps:
    # 1) A data-cleaning step (applied to all fields)
    # 2) A whitespace cleanup (can be skipped via `attributes_to_not_trim`
    #    Include a pre-processed step to convert non-break spaces to space (only if not included in trim)
    #
    before_validation :nilify_blanks, prepend: true, on: [:create, :update], unless: -> {destroyed?} # force this to be the first processor

    # You can add attributes to exclude from trimming
    # by passing them to this variable
    class_attribute :attributes_to_not_trim
  end

  module ClassMethods
    # @param [Symbol, Array] attributes
    # @return [Symbol]
    def ignore_whitespace_on(*attributes) # this assigns the attributes to be trimmed
      begin
        self.attributes_to_not_trim = attributes.map(&:to_sym)
      end
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

      # Everything is cleanable
      value = Utilities::Strings.clean(value)

      if value.blank? # non-breaking white is detected here!
        write_attribute(column, nil)
      else
        # Some things are trimmable
        value = Utilities::Rails::Strings.nil_squish_strip(value) if trimmable?(column)

        write_attribute(column, value)
      end
    end
  end

  # @param attribute [Symbol]
  def trimmable?(attribute)
    if self.attributes_to_not_trim # there are some
      return false if attributes_to_not_trim.include?(attribute.to_sym)
    end
    true
  end

end

# When we remove eager load from config/routes then this can come back in
# ApplicationRecord.send(:include, NilifyBlanks)
