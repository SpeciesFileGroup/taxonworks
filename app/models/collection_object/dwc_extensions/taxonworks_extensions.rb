module CollectionObject::DwcExtensions::TaxonworksExtensions

  extend ActiveSupport::Concern

  included do
    # !! Hash key order here determines DwC export header order !!

    # hash of api_method_name => column_name
    EXTENSION_CO_FIELDS = {
      collection_object_id: :id
    }.freeze

    EXTENSION_CE_FIELDS = {
      collecting_event_id: :id,
      elevation_precision: :elevation_precision
    }.freeze

    EXTENSION_DWC_OCCURRENCE_FIELDS = {
      dwc_occurrence_id: :id
    }

    # !!!! If you extend this then dwc/data.rb will have to be refactored (a spec will fail)
    # TODO: this is introducing a lot of overhead for little payoff here,
    # adding n(records) queries when n = 1 would work
    # It draws from taxon_name cached field
    EXTENSION_COMPUTED_FIELDS = {
      otu_name: :otu_name,  # delegated to OTU
    }.freeze

    # !! Order here determines DwC export header order for these fields !!
    EXTENSION_FIELDS = (
      EXTENSION_COMPUTED_FIELDS.keys +
      EXTENSION_CE_FIELDS.keys +
      EXTENSION_CO_FIELDS.keys +
      EXTENSION_DWC_OCCURRENCE_FIELDS.keys
    ).freeze
  end
end
