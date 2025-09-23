# A concern on media items like images and sounds.
module Shared::Dwc::MediaExtensions
  extend ActiveSupport::Concern

  # Shared implementation amongst all media sources.
  DWC_MEDIA_SHARED_EXTENSION_MAP = {
    identifier: :dwc_media_identifier,
    providerManagedID: :dwc_media_provider_managed_id, # TODO currently .id ??
    'dc:rights': :dwc_media_dc_rights,
    'dcterms:rights': :dwc_media_dcterms_rights,
    Owner: :dwc_media_owner,
    'dc:creator': :dwc_media_dc_creator,
    'dcterms:creator': :dwc_media_dcterms_creator
  }.freeze

  def dwc_media_identifier
    # Images and sounds are unlikely to have a uuid or uri, so namespace with
    # class name (this field is suposed to be unique).
    "#{self.class.name.downcase}:#{uuid || uri || id}"
  end

  def dwc_media_provider_managed_id
    id
  end

  def dwc_media_dc_rights
    dwc_media_dcterms_rights
  end

  def dwc_media_dcterms_rights
    CREATIVE_COMMONS_LICENSES[
      self.class
        .joins(:attribution)
        .where(id: id)
        .pluck('attributions.license')
        .first&.license
    ]&.[](:link)
  end

  def dwc_media_owner
    self.class
      .joins(attribution: {roles: :person})
      .where(roles: {type: 'AttributionOwner'})
      .where(id: id)
      .pluck('people.cached')
      .join(CollectionObject::DWC_DELIMITER)
  end

  def dwc_media_dc_creator
    self.class
      .joins(attribution: {roles: :person})
      .where(roles: {type: 'AttributionCreator'})
      .where(id: id)
      .pluck('people.cached')
      .join(CollectionObject::DWC_DELIMITER)
  end

  def dwc_media_dcterms_creator
    self.class
      .joins(attribution: {roles: {person: :identifiers}})
      .where(roles: {type: 'AttributionCreator'})
      .where(id: id)
      .where("identifiers.type = 'Identifier::Global::Orcid' OR identifiers.type = 'Identifier::Global::Wikidata'")
      .pluck('identifiers.cached')
      .join(CollectionObject::DWC_DELIMITER)
  end

end