require 'digest/bubblebabble'

module BatchLoad
  # TODO: Originally transliterated from Import::CollectionObjects: Remove this to-do after successful operation.
  class Import::Descriptors < BatchLoad::Import

    SAVE_ORDER = [:descriptor]

    attr_accessor :descriptors

    # @param [Hash] args
    def initialize(**args)
      @descriptors = {}
      super(**args)
    end

  end
end

