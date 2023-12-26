module CollectionObject::DwcExtensions::TaxonworksExtensions

  extend ActiveSupport::Concern

  included do
    EXTENSION_FIELDS_MAP = {
      otu_name: :otu_name,  # delegated to OTU through BiologicalExtensions
      elevation_precision: :extension_elevation_precision,
    }.freeze
  end

  def extension_elevation_precision
    collecting_event&.elevation_precision
  end
end
