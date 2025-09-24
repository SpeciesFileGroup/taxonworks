module Image::DwcMediaExtensions
  extend ActiveSupport::Concern

  include Shared::Dwc::MediaExtensions

  # Only implementations specific to Image. See
  # Shared::Dwc::MediaExtensions#DWC_MEDIA_SHARED_EXTENSION_MAP as well.
  DWC_MEDIA_IMAGE_EXTENSION_MAP = {
    'dc:type': :dwc_media_dc_type,
    #'dcmi:type': :dwc_media_dcmi_type,
    accessURI: :dwc_media_access_uri,
    'dc:format': :dwc_media_dc_format,
    # 'dcterms:format',
    PixelXDimension: :dwc_media_pixel_x_dimension,
    PixelYDimension: :dwc_media_pixel_y_dimension,
  }.freeze

  def darwin_core_media_extension_image_row
    h = {}
    (DWC_MEDIA_IMAGE_EXTENSION_MAP.merge(Shared::Dwc::MediaExtensions::DWC_MEDIA_SHARED_EXTENSION_MAP)).each do |k, v|
      h[k] = send(v)
    end

    h
  end

  def dwc_media_dc_type
    'Image'
  end

  def dwc_media_dcmi_type
    'http://purl.org/dc/dcmitype/StillImage'
  end

  def dwc_media_dc_format
    image_file_content_type
  end

  def dwc_media_access_uri
    # TODO: can we make Image::Helpers.short_image_url work in this background
    # context instead?
    Shared::Api.image_link(self)
  end

  def dwc_media_pixel_x_dimension
    width
  end

  def dwc_media_pixel_y_dimension
    height
  end
end