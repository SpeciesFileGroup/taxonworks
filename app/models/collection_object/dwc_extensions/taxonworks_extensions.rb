module CollectionObject::DwcExtensions::TaxonworksExtensions

  extend ActiveSupport::Concern

  included do
    # hash of api_method_name => column_name
    EXTENSION_CO_FIELDS = {
      collection_object_id: :id
    }.freeze

    EXTENSION_CE_FIELDS = {
      collecting_event_id: :id,
      elevation_precision: :elevation_precision
    }.freeze

    EXTENSION_COMPUTED_FIELDS = {
      otu_name: :otu_name,  # delegated to OTU through BiologicalExtensions
    }.freeze

    EXTENSION_FIELDS = (EXTENSION_CO_FIELDS.keys + EXTENSION_CE_FIELDS.keys + EXTENSION_COMPUTED_FIELDS.keys).freeze
  end
end
