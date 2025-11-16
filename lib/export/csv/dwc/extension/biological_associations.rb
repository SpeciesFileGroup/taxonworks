# CSV for for a ResourceRelationship based extension
#
module Export::CSV::Dwc::Extension::BiologicalAssociations

  # See also  BiologicalAssociation::DwcExtensions::DWC_EXTENSION_MAP, the two play off each other.
  # Maintain this for order.
  HEADERS_HASH = {
    # Required by dwca to link to core file, not part of the extension. This
    # determines the object on which this relationship will be displayed.
    coreid: '',
    resourceRelationshipID: 'http://rs.tdwg.org/dwc/terms/resourceRelationshipID',
    resourceID: 'http://rs.tdwg.org/dwc/terms/resourceID',
    'TW:Resource': Export::Dwca::LOCAL_RESOURCE_RELATIONSHIP_TERMS[:'TW:Resource'],
    relationshipOfResourceID: 'http://rs.tdwg.org/dwc/terms/relationshipOfResourceID',
    relationshipOfResource: 'http://rs.tdwg.org/dwc/terms/relationshipOfResource',
    relatedResourceID: 'http://rs.tdwg.org/dwc/terms/relatedResourceID',
    'TW:RelatedResource': Export::Dwca::LOCAL_RESOURCE_RELATIONSHIP_TERMS[:'TW:RelatedResource'],
    relationshipAccordingTo: 'http://rs.tdwg.org/dwc/terms/relationshipAccordingTo',
    relationshipEstablishedDate: 'http://rs.tdwg.org/dwc/terms/relationshipEstablishedDate',
    relationshipRemarks: 'http://rs.tdwg.org/dwc/terms/relationshipRemarks'
  }.freeze

  HEADERS = HEADERS_HASH.keys.freeze

  HEADERS_NAMESPACES = HEADERS_HASH.values.freeze

  def self.csv(scope, biological_association_relations_to_core)
    scope_with_includes = scope.includes(
      :biological_association_subject,  # Otu or CollectionObject (polymorphic)
      :biological_association_object,   # Otu or CollectionObject (polymorphic)
      { biological_relationship: :uris },  # Relationship with URIs
      :sources,                          # For citations
      :notes                             # For remarks
    )

    tbl = []
    tbl[0] = HEADERS

    scope_with_includes.find_each do |b|
      # The resource relation only appears on the page of the core id with which
      # it is linked, so link to both where we can.
      if biological_association_relations_to_core[:subject].include?(b.id)
        tbl << b.darwin_core_extension_row(inverted: false)
      end
      if biological_association_relations_to_core[:object].include?(b.id)
        b.rotate = true
        tbl << b.darwin_core_extension_row(inverted: true)
      end
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end


end
