module Shared::Uri
  extend ActiveSupport::Concern
  included do
    class_attribute :uri_column, instance_predicate: false, default: :uri

    validate :valid_uri
  end

  class_methods do
    # @param column_name The column of the including model that gives the uri.
    def use_uri_column(column_name)
      self.uri_column = column_name.to_sym
    end
  end

  def uri_attribute
    read_attribute(self.class.uri_column)
  end

  def valid_uri
    return if uri_attribute.nil?

    uris = URI.extract(uri_attribute)

    if uris.count == 0
      errors.add(uri_column, 'Provided URI is unparsable.')
    elsif uris.count > 1 || uris[0].length != uri_attribute.length
      errors.add(uri_column, 'More than a single URI present.')
    else
      begin
        u = URI(uri_attribute)
        scheme = u.scheme.upcase
        unless URI.scheme_list.keys.include?(scheme)
          errors.add(uri_column, "#{scheme} is not in the URI schemes list.")
        end
      rescue
        errors.add(uri_column, "Badly formed URI #{uri_attribute} detected.")
      end
    end
  end
end