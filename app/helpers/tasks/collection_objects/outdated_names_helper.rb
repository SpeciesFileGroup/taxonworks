module Tasks::CollectionObjects::OutdatedNamesHelper

  # What CoL is asked about for a CollectionObject (Vendor::Colrapi
  # .name_status): its current determination's TaxonName, else (no TaxonName)
  # the Otu's name. An Otu's own name alongside a TaxonName (e.g. a
  # morphospecies code, "Aus sp. 3") is deliberately left out - CoL can't know
  # it.
  #
  # @param collection_object [CollectionObject]
  # @return [TaxonName, String, nil]
  def outdated_names_target(collection_object)
    otu = collection_object.current_otu
    otu&.taxon_name || otu&.name
  end

end
