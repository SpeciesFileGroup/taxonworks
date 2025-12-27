# A concern on media items like images and sounds.
module Shared::Dwc::MediaExtensions
  extend ActiveSupport::Concern
  include Shared::Dwc::MediaIdentifier

  # Shared implementation amongst all media sources.
  DWC_MEDIA_SHARED_EXTENSION_MAP = {
    identifier: :dwc_media_identifier,
    providerManagedID: :dwc_media_provider_managed_id, # TODO currently .id ??
    'dc:rights': :dwc_media_dc_rights,
    'dcterms:rights': :dwc_media_dcterms_rights,
    Owner: :dwc_media_owner,
    Credit: :dwc_media_credit,
    'dc:creator': :dwc_media_dc_creator,
    'dcterms:creator': :dwc_media_dcterms_creator,
  }.freeze

  # dwc_media_identifier is now provided by Shared::Dwc::MediaIdentifier

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
        .first
    ]&.[](:link)
  end

  def dwc_media_owner
    roles = AttributionOwner
      .joins("INNER JOIN attributions ON attributions.id = roles.role_object_id AND roles.role_object_type = 'Attribution'")
      .where(attributions: {attribution_object_id: id, attribution_object_type: self.class.base_class.name})
      .order(:position)

    # Map each role to either person.cached or organization.name.
    roles.map do |role|
      if role.person_id
        Person.find(role.person_id).cached
      elsif role.organization_id
        Organization.find(role.organization_id).name
      end
    end.compact.join(Export::Dwca::DWC_DELIMITER)
  end

  def dwc_media_credit
    media = self.class
      .joins(attribution: :roles)
      .where(roles: {type: 'AttributionCopyrightHolder'})
      .where(id: id)
      .includes(:attribution)
      .first

    return nil if media.nil?

    ApplicationController.helpers.attribution_copyright_label(media.attribution)
  end

  def dwc_media_dc_creator
    self.class
      .joins(attribution: {roles: :person})
      .where(roles: {type: 'AttributionCreator'})
      .where(id: id)
      .order('roles.position')
      .pluck('people.cached')
      .join(Export::Dwca::DELIMITER)
  end

  def dwc_media_dcterms_creator
    self.class
      .joins(attribution: {roles: {person: :identifiers}})
      .where(roles: {type: 'AttributionCreator'})
      .where(id: id)
      .where("identifiers.type = 'Identifier::Global::Orcid' OR identifiers.type = 'Identifier::Global::Wikidata'")
      .order('roles.position')
      .pluck('identifiers.cached')
      .join(Export::Dwca::DELIMITER)
  end

end
