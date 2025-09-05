module Observation::DwcMediaExtensions
  extend ActiveSupport::Concern

  # Only implementations specific to Observation.
  DWC_MEDIA_OBSERVATION_EXTENSION_MAP = {
    associatedObservationReference: :dwc_media_associated_observation_reference
  }.freeze

  def darwin_core_media_extension_image_row
    h = {}
    DWC_MEDIA_OBSERVATION_EXTENSION_MAP.each do |k, v|
      h[k] = send(v)
    end

    h
  end

  def darwin_core_media_extension_sound_row
    h = {}
    DWC_MEDIA_OBSERVATION_EXTENSION_MAP.each do |k, v|
      h[k] = send(v)
    end

    h
  end

  def dwc_media_associated_observation_reference
    Shared::Api.api_link(self)
  end
end