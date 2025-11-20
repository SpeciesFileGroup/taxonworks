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

  # @param output_file [File, Tempfile] File to write to directly
  # @return [nil] Writes directly to output_file instead of returning string
  def self.csv(scope, biological_association_relations_to_core, output_file:)
    scope_with_includes = scope.includes(
      :biological_association_subject,  # Otu or CollectionObject (polymorphic)
      :biological_association_object,   # Otu or CollectionObject (polymorphic)
      { biological_relationship: :uris },  # Relationship with URIs
      :sources,                          # For citations
      :notes                             # For remarks
    )

    # Write header immediately
    output_file.puts ::CSV.generate_line(HEADERS, col_sep: "\t", encoding: Encoding::UTF_8)

    scope_with_includes.find_each do |b|
      # The resource relation only appears on the page of the core id with which
      # it is linked, so link to both where we can.
      if biological_association_relations_to_core[:subject].include?(b.id)
        output_file.puts ::CSV.generate_line(b.darwin_core_extension_row(inverted: false), col_sep: "\t", encoding: Encoding::UTF_8)
      end
      if biological_association_relations_to_core[:object].include?(b.id)
        b.rotate = true
        output_file.puts ::CSV.generate_line(b.darwin_core_extension_row(inverted: true), col_sep: "\t", encoding: Encoding::UTF_8)
      end
    end

    nil
  end


end
