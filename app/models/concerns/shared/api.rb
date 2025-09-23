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

  def self.api_link(ar, id = nil)
    s = host
    return s + '/api/v1/' if ar.nil?

    "#{s}/api/v1/#{ar.class.base_class.name.downcase.pluralize}/#{id || ar.id}"
  end

  def self.image_link(image)
    s = host
    return s if image.nil?

    token = Project.find(image.project_id).api_access_token
    long = "#{s}/api/v1/images/file/sha/#{ image.image_file_fingerprint }?project_token=#{token}"

    shorten_url(long)
  end

  def self.image_metadata_link(image)
    s = host
    return s if image.nil?

    token = Project.find(image.project_id).api_access_token
    long = "#{s}/api/v1/images/#{ image.id }?project_token=#{token}"

    shorten_url(long)
  end

  def self.sound_link(sound)
    s = host
    return s if sound.nil?

    long = "#{s}/#{Rails.application.routes.url_helpers.rails_blob_path(Sound.last.sound_file, only_path: true)}"

    shorten_url(long)
  end

  def self.shorten_url(long_url)
    s = host
    return s if long_url.nil?

    # Stores long <-> short in db.
    short_key = Shortener::ShortenedUrl.generate(long_url).unique_key

    "#{s}/s/#{short_key}"
  end
end