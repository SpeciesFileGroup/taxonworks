# Resource Relationship extension class
# Repository: http://rs.gbif.org/extension/dwc/resource_relation.xml

module Export::Dwca::GbifProfile

  class ResourceRelationship
    # Field name constants
    TAXON_ID = :taxonID
    RELATED_RESOURCE_ID = :relatedResourceID
    SCIENTIFIC_NAME = :scientificName
    RELATIONSHIP_OF_RESOURCE = :relationshipOfResource
    RELATIONSHIP_ACCORDING_TO = :relationshipAccordingTo
    RELATIONSHIP_ESTABLISHED_DATE = :relationshipEstablishedDate
    RELATIONSHIP_REMARKS = :relationshipRemarks
    RESOURCE_RELATIONSHIP_ID = :resourceRelationshipID

    # Namespace mappings
    NAMESPACES = {
      TAXON_ID => 'http://rs.tdwg.org/dwc/terms/taxonID',
      RELATED_RESOURCE_ID => 'http://rs.tdwg.org/dwc/terms/relatedResourceID',
      SCIENTIFIC_NAME => 'http://rs.tdwg.org/dwc/terms/scientificName',
      RELATIONSHIP_OF_RESOURCE => 'http://rs.tdwg.org/dwc/terms/relationshipOfResource',
      RELATIONSHIP_ACCORDING_TO => 'http://rs.tdwg.org/dwc/terms/relationshipAccordingTo',
      RELATIONSHIP_ESTABLISHED_DATE => 'http://rs.tdwg.org/dwc/terms/relationshipEstablishedDate',
      RELATIONSHIP_REMARKS => 'http://rs.tdwg.org/dwc/terms/relationshipRemarks',
      RESOURCE_RELATIONSHIP_ID => 'http://rs.tdwg.org/dwc/terms/resourceRelationshipID'
    }.freeze

    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The identifier used in the core data file representing the taxon for
    # which the current record refers. This identifier provides the link
    # between the core data record and the extension record.
    attr_accessor TAXON_ID

    # relatedResourceID (http://rs.tdwg.org/dwc/terms/relatedResourceID)
    #
    # @return [String]
    # When the related taxon occurs in the core data file, this is the
    # taxonID of that taxon.
    attr_accessor RELATED_RESOURCE_ID

    # scientificName (http://rs.tdwg.org/dwc/terms/scientificName)
    #
    # @return [String]
    # When the related taxon (the object) does not occur in the core data
    # file, refer to it by scientific name. Example: "Quercus agrifolia var.
    # oxyadenia (Torr.)"
    attr_accessor SCIENTIFIC_NAME

    # relationshipOfResource (http://rs.tdwg.org/dwc/terms/relationshipOfResource)
    #
    # @return [String]
    # The relationship of the resource identified by relatedResourceID to
    # the subject (optionally identified by the resourceID). Recommended
    # best practice is to use a controlled vocabulary.
    #
    # Example: "duplicate of", "mother of", "endoparasite of", "host to",
    # "sibling of", "valid synonym of", "located within"
    attr_accessor RELATIONSHIP_OF_RESOURCE

    # relationshipAccordingTo (http://rs.tdwg.org/dwc/terms/relationshipAccordingTo)
    #
    # @return [String]
    # The source (person, organization, publication, reference)
    # establishing the relationship between the two resources.
    #
    # Example: "Julie Woodruff"
    attr_accessor RELATIONSHIP_ACCORDING_TO

    # relationshipEstablishedDate (http://rs.tdwg.org/dwc/terms/relationshipEstablishedDate)
    #
    # @return [String]
    # The date-time on which the relationship between the two resources
    # was established. Recommended best practice is to use an encoding
    # scheme, such as ISO 8601:2004(E).
    #
    # Example: 1963-03-08T14:07-0600
    attr_accessor RELATIONSHIP_ESTABLISHED_DATE

    # relationshipRemarks (http://rs.tdwg.org/dwc/terms/relationshipRemarks)
    #
    # @return [String]
    # Comments or notes about the relationship between the two
    # resources.
    #
    # Example: "mother and offspring collected from the same nest"
    attr_accessor RELATIONSHIP_REMARKS

    # resourceRelationshipID (http://rs.tdwg.org/dwc/terms/resourceRelationshipID)
    #
    # @return [String]
    # An identifier for an instance of relationship between one resource
    # (the subject) and another (relatedResource, the object).
    #
    # Example: "231" "urn:lsid:gbif.org:usages:32567"
    attr_accessor RESOURCE_RELATIONSHIP_ID

  end
  
end
