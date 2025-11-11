module BiologicalAssociation::DwcExtensions

  extend ActiveSupport::Concern

  included do

    DWC_EXTENSION_MAP = {
      coreid: :dwc_resource_relationship_coreid, # required by dwca to link to core file, not part of extension
      resourceRelationshipID: :dwc_resource_relationship_id,
      resourceID: :dwc_resource_id,
      'TW:Resource': :dwc_resource, # a local term, not dwc
      relationshipOfResourceID: :dwc_relationship_of_resource_id,
      relationshipOfResource: :dwc_relationship_of_resource,
      relatedResourceID: :dwc_related_resource_id,
      'TW:RelatedResource': :dwc_related_resource, # a local term, not dwc
      relationshipAccordingTo: :dwc_relationship_according_to, # TODO: DwC.  Needs ID version
      relationshipEstablishedDate: :dwc_relationship_established_date, # TODO: DwC needs clarification.
      relationshipRemarks: :dwc_relationship_remarks
    }.freeze
  end

  # Don't use dwc_
  # !! inverted means subject and object have already been switched, but
  # *relationship* must use `inverted_name` instead of `name`.
  # !! Expects biological_association_index to be preloaded (via includes)
  def darwin_core_extension_row(inverted: false)
    Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS.collect{|h| send(DWC_EXTENSION_MAP[h.to_sym], inverted)}
  end

  # Don't use dwc_
  def globi_extension_json
    r = {}
     Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS.each do |h|
      if m = DWC_EXTENSION_MAP[h.to_sym]
        r[h] = send(m, false)
      end
    end
    r
  end

  def dwc_resource_relationship_coreid(inverted = false)
    # Note that this could be subject or object of the original association (see
    # note above on `inverted`), which is what we want.
    dwc_resource_id(inverted)
  end

  def dwc_resource_relationship_id(inverted = false)
    index = biological_association_index
    index.biological_association_uuid
  end

  def dwc_resource_id(inverted = false)
    index = biological_association_index
    if inverted
      index.object_uuid || index.object_id
    else
      index.subject_uuid || index.subject_id
    end
  end

  def dwc_resource(inverted = false)
    index = biological_association_index
    inverted ? index.object_label : index.subject_label
  end

  def dwc_relationship_of_resource_id(inverted = false)
    index = biological_association_index
    s = index.biological_relationship_uri || index.biological_relationship_id

    # TODO: this might mess up uri handling
    inverted ? "#{s} inverted" : s
  end

  def dwc_relationship_of_resource(inverted = false)
    index = biological_association_index
    inverted ? index.relationship_inverted_name : index.relationship_name
  end

  def dwc_related_resource_id(inverted = false)
    index = biological_association_index
    if inverted
      index.subject_uuid || index.subject_id
    else
      index.object_uuid || index.object_id
    end
  end

  def dwc_related_resource(inverted = false)
    index = biological_association_index
    inverted ? index.subject_label : index.object_label
  end

  # TODO: Should reference DOIs, Identifiers,  or identifiers in lieu of short citations
  def dwc_relationship_according_to(inverted = false)
    index = biological_association_index
    index.citations
  end

  def dwc_relationship_established_date(inverted = false)
    index = biological_association_index
    index.established_date
  end

  # TODO: Generic helper
  def dwc_relationship_remarks(inverted = false)
    index = biological_association_index
    index.remarks
  end

end
