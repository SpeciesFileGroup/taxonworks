module CollectionObject::DwcExtensions::TaxonworksExtensions

  extend ActiveSupport::Concern

  included do
    EXTENSION_FIELDS_MAP = {
      otu_name: :otu_name   # delegated to OTU through BiologicalExtensions
    }.freeze
  end
end
