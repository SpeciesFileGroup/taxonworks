# Base validation class for validator specs, follows the style described at http://devblog.orgsync.com/2013/10/29/building-custom-rails-attribute-validators/

module ValidatorsHelper
  class ValidationTester
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    def new_record?
      true
    end

    def persisted?
      false
    end

    def self.name
      'Validator'
    end

    def [](key)
      send(key)
    end

    def []=(key, value)
      send("#{key}=", value)
    end
  end
end