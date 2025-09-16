module Shared::Uri
  extend ActiveSupport::Concern
  included do
    validate :valid_uri
  end

  def valid_uri
    return if uri.nil?

    uris = URI.extract(uri)

    if uris.count == 0
      errors.add(:uri, 'URI provided by unparsable.')
    elsif uris.count > 1 || uris[0].length != uri.length
      errors.add(:uri, 'More than a single URI present.')
    else
      begin
        u = URI(uri)
        scheme = u.scheme.upcase
        unless URI.scheme_list.keys.include?(scheme)
          errors.add(:uri, "#{scheme} is not in the URI schemes list.")
        end
      rescue
        errors.add(:uri, "Badly formed URI #{uri} detected.")
      end
    end
  end
end