module FieldOccurrence::DwcExtensions::MediaExtensions
  extend ActiveSupport::Concern

  # TODO: Currently *identical* to
  # CollectionObject::DwcExtensions::MediaExtensions - if that holds up, merge.

  DWC_MEDIA_EXTENSION_MAP = {
    # identifier
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
    #'dc:rights': :dwc_media_dc_rights,
    #'dcterms:rights': :dwc_media_dcterms_rights,
    #Owner: :dwc_media_owner,
    # 'UsageTerms',
    # 'WebStatement',
    # 'licenseLogoURL',
    # 'Credit',
    # 'attributionLogoURL',
    # 'attributionLinkURL',
    # #'fundingAttribution',
    # 'dc:source',
    # 'dcterms:source',
    #'dc:creator': :dwc_media_dc_creator,
    # 'dcterms:creator',
    # 'providerLiteral', TODO??
    # 'provider', TODO??
    # 'metadataCreatorLiteral',
    # 'metadataCreator',
    # 'metadataProviderLiteral',
    # 'metadataProvider',
    description: :dwc_media_description, # currently from depiction/conveyance, but maybe should be image/sound notes??
    caption: :dwc_media_caption,
    # 'language',
    # 'language',
    # #'physicalSetting',
    # 'CVterm',
    # 'subjectCategoryVocabulary',
    #tag: :dwc_media_tag, # TODO list tags??
    # 'LocationShown', # TODO?? could be AD of depiction/conveyance of image/sound (on otu)
    # 'WorldRegion',
    # 'CountryCode', TODO: AD on image/sound for all of these ?? Yes.
    # 'CountryName',
    # 'ProvinceState',
    # 'City',
    # 'Sublocation',
    # 'temporal',
    # 'CreateDate',
    # 'timeOfDay',
    #taxonCoverage: :dwc_media_taxon_coverage,
    scientificName: :dwc_media_scientific_name,
    # 'identificationQualifier',
    vernacularName: :dwc_media_vernacular_name,
    # 'nameAccordingTo',
    # 'scientificNameID',
    # 'otherScientificName',
    identifiedBy: :dwc_media_identified_by,
    dateIdentified: :dwc_media_date_identified,
    # 'taxonCount',
    # #'subjectPart',
    sex: :dwc_media_sex,
    lifeStage: :dwc_media_life_stage,
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
    # 'associatedSpecimenReference', TODO ??
    # 'associatedObservationReference', TODO ??
    # 'accessURI', TODO ?? Does user fill this in after the fact with TP links?
    #'dc:format': :dwc_media_dc_format,
    # 'dcterms:format',
    # 'variantLiteral',
    # 'variant',
    # 'variantDescription',
    # 'furtherInformationURL',
    #'licensingException',
    #'serviceExpectation',
    #'hashFunction',
    #'hashValue',
    #PixelXDimension: dwc_pixel_x_dimension,
    #PixelYDimension: dwc_pixel_y_dimension
  }.freeze

  def darwin_core_media_extension_rows
    rv = []
    rv += images.collect do |i|
      image_dwc_array =
        Export::CSV::Dwc::Extension::Media::HEADERS.collect do |h|
          dwc_reader = DWC_MEDIA_EXTENSION_MAP[h.to_sym]
          dwc_reader.present? && respond_to?(dwc_reader) ?
            send(dwc_reader, i) : nil
        end

      image_fields_hash = i.darwin_core_media_extension_image_row

      # Merge image_fields_hash data into image_dwc_array.
      image_fields_hash.each { |k, v| image_dwc_array[extension_map_index(k)] = v }

      image_dwc_array
    end

    rv += sounds.collect do |s|
      sound_dwc_array =
        Export::CSV::Dwc::Extension::Media::HEADERS.collect do |h|
          dwc_reader = DWC_MEDIA_EXTENSION_MAP[h.to_sym]
          dwc_reader.present? && respond_to?(dwc_reader) ?
            send(dwc_reader, s) : nil
        end

      sound_fields_hash = s.darwin_core_media_extension_sound_row

      # Merge sound_fields_hash data into sound_dwc_array.
      sound_fields_hash.each { |k, v| sound_dwc_array[extension_map_index(k)] = v }

      sound_dwc_array
    end

    rv
  end

  def extension_map_index(key)
    # TODO: freeze the inverse?
    Export::CSV::Dwc::Extension::Media::HEADERS.index(key.to_s)
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

  def dwc_media_scientific_name(o)
    dwc_scientific_name
  end

  def dwc_media_vernacular_name(o)
    td = taxon_determination
    otu = td&.otu
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
end
