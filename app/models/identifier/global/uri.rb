# URI_SCHEMES = URI.scheme_list.keys # + ['UDP']

# Universal Resource Identifier
class Identifier::Global::Uri < Identifier::Global

  validate :identifier_is_uri

  def identifier_is_uri
    unless identifier.nil?
      uris = URI.extract(identifier)
      if uris.count == 0
        errors.add(:identifier, 'No URI detected.')
      else
        unless (identifier.length == uris[0].length) and (uris.count == 1)
          errors.add(:identifier, 'More than a single URI present.')
        else
          begin
            uri = URI(identifier)
            scheme = uri.scheme.upcase
            unless URI.scheme_list.keys.include?(scheme)
              errors.add(:identifier, "#{scheme} is not in the URI schemes list.")
            end
          rescue
            errors.add(:identifier, "Badly formed URI #{identifier} detected.")
          end
        end
      end
    end
  end

end
