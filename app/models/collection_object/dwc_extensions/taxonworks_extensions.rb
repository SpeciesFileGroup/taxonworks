module CollectionObject::DwcExtensions::TaxonworksExtensions

  extend ActiveSupport::Concern

  included do
    EXTENSION_CO_FIELDS = [].freeze

    EXTENSION_CE_FIELDS = [
      :elevation_precision
    ].freeze

    EXTENSION_COMPUTED_FIELDS = {
      otu_name: :otu_name,  # delegated to OTU through BiologicalExtensions
    }.freeze

    EXTENSION_FIELDS = (EXTENSION_CO_FIELDS + EXTENSION_CE_FIELDS + EXTENSION_COMPUTED_FIELDS.keys).freeze
  end
end
