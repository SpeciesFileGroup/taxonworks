module Shared::Api
  extend ActiveSupport::Concern

  # TODO: can we do away with these? Standard helpers would be preferred.
  # !! These can be useful in a background or other context where you don't have
  # the normal request context and all that comes with it, but standard helpers
  # should be preffered in general. !!

  def self.host
    s = ENV['SERVER_NAME']
    if s.nil?
      'http://127.0.0.1:3000'
    else
      'https://' + s
    end
  end

  def self.api_base_path(model_or_instance)
    return "#{host}/api/v1" if model_or_instance.nil?

    klass = model_or_instance.is_a?(Class) ? model_or_instance : model_or_instance.class
    "#{host}/api/v1/#{klass.base_class.name.tableize}"
  end

  def self.api_link(ar, id = nil)
    return "#{host}/api/v1" if ar.nil?

    "#{api_base_path(ar)}/#{id || ar.id}"
  end

  def self.api_link_for_model_id(klass, id)
    return "#{host}/api/v1" if klass.nil?

    "#{api_base_path(klass)}/#{id}"
  end

  def self.image_link(image, raise_on_no_token: true, token: nil)
    return host if image.nil?

    token ||= Project.find(image.project_id).api_access_token
    if token.nil? && raise_on_no_token
      raise TaxonWorks::Error, 'No project token available for image link!'
    end

    shorten_url(image_file_long_url(image.image_file_fingerprint, token))
  end

  def self.image_metadata_link(image, raise_on_no_token: true, token: nil)
    return host if image.nil?

    token ||= Project.find(image.project_id).api_access_token
    if token.nil? && raise_on_no_token
      raise TaxonWorks::Error, 'No project token available for image metadata link!'
    end

    shorten_url(image_metadata_long_url(image.id, token))
  end

  def self.sound_link(sound)
    s = host
    return s if sound.nil?

    long = "#{s}/#{Rails.application.routes.url_helpers.rails_blob_path(sound.sound_file, only_path: true)}"

    shorten_url(long)
  end

  def self.sound_metadata_link(sound, raise_on_no_token: true, token: nil)
    s = host
    return s if sound.nil?

    token ||= Project.find(sound.project_id).api_access_token
    if token.nil? && raise_on_no_token
      raise TaxonWorks::Error, 'No project token available for sound link!'
    end

    long = "#{s}/api/v1/sounds/#{ sound.id }?project_token=#{token}"

    shorten_url(long)
  end


  def self.shorten_url(long_url)
    s = host
    return s if long_url.nil?

    # Stores long <-> short in db.
    short_key = Shortener::ShortenedUrl.generate(long_url).unique_key

    "#{s}/s/#{short_key}"
  end

  # URL prefix for image file access.
  # @return [String] URL prefix
  def self.image_file_url_prefix
    "#{host}/api/v1/images/file/sha/"
  end

  # URL prefix for image metadata (without image_id or token).
  # @return [String] URL prefix
  def self.image_metadata_url_prefix
    "#{host}/api/v1/images/"
  end

  # Build long URL for image file access without shortening.
  # @param fingerprint [String] image_file_fingerprint
  # @param token [String] project API access token
  # @return [String] full long URL
  def self.image_file_long_url(fingerprint, token)
    "#{image_file_url_prefix}#{fingerprint}?project_token=#{token}"
  end

  # Build long URL for image metadata without shortening.
  # @param image_id [Integer] image ID
  # @param token [String] project API access token
  # @return [String] full long URL
  def self.image_metadata_long_url(image_id, token)
    "#{image_metadata_url_prefix}#{image_id}?project_token=#{token}"
  end

  # Build long URL for sled image extraction.
  # @param fingerprint [String] image_file_fingerprint
  # @param svg_view_box [String] SVG viewBox value "x y width height"
  # @param token [String] project API access token
  # @return [String] full long URL for cropped sled image
  def self.sled_image_file_long_url(fingerprint, svg_view_box, token)
    x, y, w, h = svg_view_box.split(' ')
    box_width = w.to_i
    box_height = h.to_i

    "#{image_file_url_prefix}#{fingerprint}/scale_to_box/#{x.to_i}/#{y.to_i}/#{w.to_i}/#{h.to_i}/#{box_width}/#{box_height}?project_token=#{token}"
  end

  # Build short URL from unique key
  # @param unique_key [String] shortened URL unique key
  # @return [String] full short URL
  def self.short_url_from_key(unique_key)
    "#{host}/s/#{unique_key}"
  end

  # Bulk lookup existing shortened URLs
  # Returns a hash mapping long URLs to their short keys
  # @param long_urls [Array<String>] array of long URLs to lookup
  # @return [Hash<String, String>] hash mapping long_url => unique_key
  def self.bulk_lookup_shortened_urls(long_urls)
    return {} if long_urls.empty?

    ::Shortener::ShortenedUrl
      .where(url: long_urls)
      .pluck(:url, :unique_key)
      .to_h
  end
end