# URI_SCHEMES = URI.scheme_list.keys # + ['UDP']

# Universal Resource Identifier
class Identifier::Global::Uri < Identifier::Global
  include Shared::Uri
  use_uri_column(:identifier)
end
