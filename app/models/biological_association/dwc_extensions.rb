module BiologicalAssociation::DwcExtensions

  extend ActiveSupport::Concern

  included do

    DWC_EXTENSION_MAP = {
      resourceRelationshipID: :dwc_resource_relationship_id,
      resourceID: :dwc_resource_id,
      resource: :dwc_resource, # !! NOT A DWC FIELD
      relationshipOfResourceID: :dwc_relationship_of_resource_id,
      relationshipOfResource: :dwc_relationship_of_resource,
      relatedResourceID: :dwc_related_resource_id,
      relatedResource: :dwc_related_resource, # !! NOT A DWC FIELD
      relationshipAccordingTo: :dwc_relationship_according_to, # TODO: DwC.  Needs ID version
      relationshipEstablishedDate: :dwc_relationship_established_date, # TODO: DwC needs clarification.
      relationshipRemarks: :dwc_relationship_remarks
    }.freeze
  end

  # Don't use dwc_
  def darwin_core_extension_row
    Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS.collect{|h| send( DWC_EXTENSION_MAP[h.to_sym] )}
  end

  # Don't use dwc_
  def globi_extension_json
    r = {}
     Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS.each do |h|
      if m = DWC_EXTENSION_MAP[h.to_sym]
        r[h] = send(m)
      end
    end
    r
  end

  def darwin_core_extension_json

  end

  def dwc_resource_relationship_id
    uuid || id
  end

  def dwc_resource_id
    case biological_association_subject.class.base_class.name
    when 'Otu'
      biological_association_subject.uuid || biological_association_subject.uri || biological_association_subject.id
    when 'CollectionObject'
      biological_association_subject.dwc_occurrence_id
    end
  end

  def dwc_resource
    case biological_association_subject.class.base_class.name
    when 'Otu'
      ApplicationController.helpers.label_for_otu(biological_association_subject)
    when 'CollectionObject'
      ApplicationController.helpers.label_for_collection_object(biological_association_subject)
    end
  end

  def dwc_relationship_of_resource_id
    biological_relationship.uris.first&.cached || biological_relationship_id
  end

  def dwc_relationship_of_resource
    biological_relationship.name
  end

  def dwc_related_resource_id
    case biological_association_object.class.base_class.name
    when 'Otu'
      biological_association_object.uuid || biological_association_object.uri || biological_association_object.id
    when 'CollectionObject'
      biological_association_object.dwc_occurrence_id
    end
  end

  def dwc_related_resource
    case biological_association_object.class.base_class.name
    when 'Otu'
      ApplicationController.helpers.label_for_otu(biological_association_object)
    when 'CollectionObject'
      ApplicationController.helpers.label_for_collection_object(biological_association_object)
    end
  end

  # TODO: Should reference DOIs, Identifiers,  or identifiers in lieu of short citations
  def dwc_relationship_according_to
    ApplicationController.helpers.short_sources_tag(sources)

    # Could be collectors (ORCID or ...)
    # Could be citation providers

    t = [biological_association_subject_type , biological_association_object_type]

    case t
    when %w{Otu Otu} # Published or nothing
      ApplicationController.helpers.short_sources_tag(sources)
    when %w{CollectionObject Otu} # Assume exists on label
      biological_association_subject.dwc_recorded_by || ApplicationController.helpers.short_sources_tag(sources)
    when %w{Otu CollectionObject} # Assume exists on label
      biological_association_object.dwc_recorded_by || ApplicationController.helpers.short_sources_tag(sources)
    when %w{CollectionObject CollectionObject}
      # Lots of assumptions behind this.  What if specimens were marked as collected in 2 different events, that would be odd
      # but perhaps not impossible
      biological_association_subject.dwc_recorded_by || biological_association_object.dwc_recorded_by
    else
      'BAD DATA: TYPE ERROR'
    end
  end

  def dwc_relationship_established_date
    t = [biological_association_subject_type , biological_association_object_type]

    case t
    when %w{Otu Otu}
      ApplicationController.helpers.short_sources_year_tag(sources)
    when %w{CollectionObject Otu}
      biological_association_subject.dwc_event_date || ApplicationController.helpers.short_sources_year_tag(sources)
    when %w{Otu CollectionObject}
      biological_association_object.dwc_event_date || ApplicationController.helpers.short_sources_year_tag(sources)
    when %w{CollectionObject CollectionObject}
      # Lots of assumptions behind this.  What if specimens were marked as collected in 2 different events, that would be odd
      # but perhaps not impossible
      biological_association_subject.dwc_event_date || biological_association_object.dwc_event_date
    else
      'BAD DATA: TYPE ERROR'
    end
  end

  # TODO: Generic helper
  def dwc_relationship_remarks
    Utilities::Strings.sanitize_for_csv( notes.collect{|n| n.text}.join(' | ')).presence
  end

end
