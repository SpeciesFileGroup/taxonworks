# A concern on media items like images and sounds.
module Shared::Dwc::MediaExtensions
  extend ActiveSupport::Concern

  # Shared implementation amongst all media sources.
  DWC_MEDIA_SHARED_EXTENSION_MAP = {
    identifier: :dwc_media_identifier,
    providerManagedID: :dwc_media_provider_managed_id, # TODO currently .id ??
    accessURI: :dwc_media_access_uri,
    'dc:rights': :dwc_media_dc_rights,
    'dcterms:rights': :dwc_media_dcterms_rights,
    Owner: :dwc_media_owner,
    'dc:creator': :dwc_media_dc_creator,
  }.freeze

  def dwc_media_identifier
    uuid || uri || id
  end

  def dwc_media_provider_managed_id
    id
  end


  def dwc_media_access_uri
    Shared::Api.api_link(self)
  end

  def dwc_media_dc_rights
    dwc_media_dcterms_rights
  end

  def dwc_media_dcterms_rights
    CREATIVE_COMMONS_LICENSES[
      self.class
        .joins(:attribution)
        .where(id: id)
        .select('attributions.license')
        .first&.license
    ]&.[](:link)
  end

  def dwc_media_owner
    self.class
      .joins(attribution: {roles: :person})
      .where(roles: {type: 'AttributionOwner'})
      .where(id: id)
      .select('people.cached')
      .map { |o| o.cached }.join(CollectionObject::DWC_DELIMITER)
  end

  def dwc_media_dc_creator
    self.class
      .joins(attribution: {roles: :person})
      .where(roles: {type: 'AttributionCreator'})
      .where(id: id)
      .select('people.cached')
      .map { |c| c.cached }.join(CollectionObject::DWC_DELIMITER)
  end

end