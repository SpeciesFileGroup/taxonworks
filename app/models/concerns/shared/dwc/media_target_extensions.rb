# A concern on media 'targets' (i.e. things that are conveyed or depicted by
# media) like CollectionObjects and FieldOccurrences.
module Shared::Dwc::MediaTargetExtensions
  extend ActiveSupport::Concern

  # See https://rs.gbif.org/extension/ac/audiovisual_2024_11_07.xml and
  # Export::CSV::Dwc::Extension::Media::HEADERS for the original list. The list
  # here is uncommented only for those properties actually mapped by this
  # concern; see concerns on Image, Sound, and Observation for others.
  DWC_MEDIA_EXTENSION_MAP = {
    coreid: :dwc_media_coreid,
    # identifier - !? should be the file SHA
    #'dc:type': :dwc_media_dc_type, # TODO: is the prefix the way to do this?
    #'dcmi:type': :dwc_media_dcmi_type,
    # 'subtypeLiteral',
    # 'subtype',
    # 'title',
    # 'modified', # TODO: updated_at ??
    # 'MetadataDate',
    # 'metadataLanguageLiteral',
    # 'metadataLanguage',
    #providerManagedID: :dwc_media_provider_managed_id, # currently id ??
    # #'Rating',
    # #'commenterLiteral',
    # #'commenter',
    # #'comments',
    # #'reviewerLiteral',
    # #'reviewer',
    # #'reviewerComments',
    # 'available',
    # 'hasServiceAccessPoint',
    # !! 'dc:rights': :dwc_media_dc_rights,
    # 'dcterms:rights': :dwc_media_dcterms_rights,
    # !! Owner: :dwc_media_owner,
    # !? 'UsageTerms',
    # 'WebStatement',
    # 'licenseLogoURL',
    # !! 'Credit',
    # 'attributionLogoURL',
    # 'attributionLinkURL',
    # #'fundingAttribution',
    # 'dc:source',
    # 'dcterms:source',
    # !! 'dc:creator': :dwc_media_dc_creator,
    # !! 'dcterms:creator',
    # 'providerLiteral', TODO??
    # 'provider', TODO?? (really vague concept)
    # 'metadataCreatorLiteral',
    # 'metadataCreator',
    # 'metadataProviderLiteral',
    # 'metadataProvider',
    description: :dwc_media_description, # currently from depiction/conveyance <-- this is right
    caption: :dwc_media_caption,
    # 'language',
    # 'language',
    # #'physicalSetting',
    # 'CVterm',
    # 'subjectCategoryVocabulary',
    #tag: :dwc_media_tag, # TODO list tags??
    # 'LocationShown', # TODO?? could be AD of depiction/conveyance of image/sound (on otu)
    # 'WorldRegion',
    #CountryCode: :dwc_media_country_code,
    CountryName: :dwc_media_country_name, # !! Not needed, inferred from core
    ProvinceState: :dwc_media_province_state, # !! Not needed, inferred from core
    # 'City',
    # 'Sublocation',
    # 'temporal',
    # 'CreateDate',
    # 'timeOfDay',
    #taxonCoverage: :dwc_media_taxon_coverage,
    scientificName: :dwc_media_scientific_name, # !! Not needed, inferred from core
    # 'identificationQualifier',
    vernacularName: :dwc_media_vernacular_name, # !! Not needed, inferred from core
    # 'nameAccordingTo',
    # 'scientificNameID',
    # 'otherScientificName',
    identifiedBy: :dwc_media_identified_by, # !! Not needed, inferred from core
    dateIdentified: :dwc_media_date_identified, # !! Not needed, inferred from core
    # 'taxonCount',
    # #'subjectPart',
    sex: :dwc_media_sex,  # !! not needed, inferred from core
    lifeStage: :dwc_media_life_stage, # !! not needed, inferred from core
    # 'subjectOrientation',
    # 'preparations',
    # 'LocationCreated',
    # 'digitizationDate',
    # #'captureDevice',
    # #'resourceCreationTechnique',
    # #'IDofContainingCollection',
    # 'relatedResourceID',
    # 'providerID',
    # 'derivedFrom',
    associatedSpecimenReference: :dwc_media_associated_specimen_reference,
    # 'associatedObservationReference',
    # !! 'accessURI',
    # !! 'dc:format': :dwc_media_dc_format,
    # 'dcterms:format',
    # 'variantLiteral',
    # 'variant',
    # 'variantDescription',
    #  !! 'furtherInformationURL', (should be short URL for images (hitting api/v1/images/123))
    #'licensingException',
    #'serviceExpectation',
    #'hashFunction',
    #'hashValue',
    # !! PixelXDimension: dwc_pixel_x_dimension,
    # !! PixelYDimension: dwc_pixel_y_dimension
  }.freeze

  def darwin_core_media_extension_rows
    rv = []
    images_array = (
      images.map { |i| { image: i, observation: nil }} +
      observations.map { |o| o.images.map { |i| { image: i, observation: o }} }
    ).flatten
    rv += images_array.collect do |i|
      image_dwc_array =
        Export::CSV::Dwc::Extension::Media::HEADERS.collect do |h|
          dwc_reader = DWC_MEDIA_EXTENSION_MAP[h.to_sym]
          dwc_reader.present? && respond_to?(dwc_reader) ?
            send(dwc_reader, i[:image]) : nil
        end

      image_fields_hash = i[:image].darwin_core_media_extension_image_row
      # Merge image_fields_hash data into image_dwc_array.
      image_fields_hash.each { |k, v| image_dwc_array[extension_map_index(k)] = v }

      if i[:observation]
        observation_fields_hash = i[:observation].darwin_core_media_extension_image_row
        observation_fields_hash.each { |k, v| image_dwc_array[extension_map_index(k)] = v }
      end

      image_dwc_array
    end

    sounds_array = (
      sounds.map { |s| { sound: s, observation: nil }} #+
      #observations.map { |o| o.sounds.map { |s| { sound: s, observation: o }} }
    ).flatten
    rv += sounds_array.collect do |s|
      sound_dwc_array =
        Export::CSV::Dwc::Extension::Media::HEADERS.collect do |h|
          dwc_reader = DWC_MEDIA_EXTENSION_MAP[h.to_sym]
          dwc_reader.present? && respond_to?(dwc_reader) ?
            send(dwc_reader, s[:sound]) : nil
        end

      sound_fields_hash = s[:sound].darwin_core_media_extension_sound_row
      # Merge sound_fields_hash data into sound_dwc_array.
      sound_fields_hash.each { |k, v| sound_dwc_array[extension_map_index(k)] = v }

      # TODO: bring this back once conveyances are back on Observations.
      # if s[:observation]
      #   observation_fields_hash = s[:observation].darwin_core_media_extension_sound_row
      #   observation_fields_hash.each { |k, v| sound_dwc_array[extension_map_index(k)] = v }
      # end

      sound_dwc_array
    end

    rv
  end

  def extension_map_index(key)
    Export::CSV::Dwc::Extension::Media::HEADERS_INDEX[key.to_sym]
  end

  def dwc_media_coreid(o)
    dwc_occurrence.id
  end

  def dwc_media_description(o)
    case o.class.name
    when 'Image'
      d = depictions.select { |d| d.image_id == o.id }.first
      d.figure_label if d
    when 'Sound'
      o.name
    else
      nil
    end
  end

  def dwc_media_caption(o)
    case o.class.name
    when 'Image'
      d = depictions.select { |d| d.image_id == o.id }.first
      d.caption if d
    else
      nil
    end
  end

# TODO? country code isn't cached; we could try to look it up off GAs
#  def dwc_media_country_code(o)
#  end

  def dwc_media_country_name(o)
    dwc_country
  end

  def dwc_media_province_state(o)
    dwc_state_province
  end

  def dwc_media_scientific_name(o)
    dwc_scientific_name
  end

  def dwc_media_vernacular_name(o)
    otu = current_otu

    return nil if otu.nil?

    # TODO: include countries?
    CommonName
      .joins(:otu)
      .where(otu: {id: otu.id})
      .map(&:name)
      .join(CollectionObject::DWC_DELIMITER)
  end

  def dwc_media_identified_by(o)
    dwc_identified_by
  end

  def dwc_media_date_identified(o)
    dwc_date_identified
  end

  def dwc_media_sex(o)
    dwc_sex
  end

  def dwc_media_life_stage(o)
    dwc_life_stage
  end

  def dwc_media_associated_specimen_reference(o)
    if self.is_a?(CollectionObject)
      Shared::Api.api_link(self)
    end
  end
end
