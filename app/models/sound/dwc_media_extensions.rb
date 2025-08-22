module Sound::DwcMediaExtensions
  extend ActiveSupport::Concern

  include Shared::Dwc::MediaExtensions

  # Only implementations specific to Sound. See
  # Shared::Dwc::MediaExtensions#DWC_MEDIA_SHARED_EXTENSION_MAP as well.
  DWC_MEDIA_SOUND_EXTENSION_MAP = {
    'dc:type': :dwc_media_dc_type,
    'dcmi:type': :dwc_media_dcmi_type,
    'dc:format': :dwc_media_dc_format,
    # 'dcterms:format',
    accessURI: :dwc_media_access_uri,
  }.freeze

  def darwin_core_media_extension_sound_row
    h = {}
    (DWC_MEDIA_SOUND_EXTENSION_MAP.merge(Shared::Dwc::MediaExtensions::DWC_MEDIA_SHARED_EXTENSION_MAP)).each do |k, v|
      h[k] = send(v)
    end

    h
  end

  def dwc_media_dc_type
    'Sound'
  end

  def dwc_media_dcmi_type
    'http://purl.org/dc/dcmitype/Sound'
  end

  def dwc_media_dc_format
    "#{sound_file.content_type}"
  end

  def dwc_media_access_uri
    Shared::Api.sound_link(self)
  end
end