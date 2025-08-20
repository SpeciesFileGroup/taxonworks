module Image::DwcMediaExtensions
  extend ActiveSupport::Concern

  include Shared::Dwc::MediaExtensions

  # Only implementations specific to Image. See
  # Shared::Dwc::MediaExtensions#DWC_MEDIA_SHARED_EXTENSION_MAP as well.
  DWC_MEDIA_IMAGE_EXTENSION_MAP = {
    'dc:type': :dwc_media_dc_type,
    'dcmi:type': :dwc_media_dcmi_type,
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
    'jpg'
  end

  def dwc_media_pixel_x_dimension
    width
  end

  def dwc_media_pixel_y_dimension
    height
  end
end