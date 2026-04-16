# Web of Science ID - https://www.webofknowledge.com/
class Identifier::Global::WebOfScience < Identifier::Global
    validate :namespace_format
    validate :source_use_only

    before_save :upcase_identifier

    NAMESPACES = %w{WOS ZOOREC}.freeze

    URI_BASE = 'https://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=Publons&SrcAuth=Publons_CEL&DestLinkType=FullRecord&DestApp=WOS_CPL&KeyUT='.freeze

    def uri
      URI_BASE + identifier
    end
  
    private

    def namespace_format
      errors.add(:identifier, 'Identifier is not prefixed with an recognized "namespace".') unless identifier =~ /^WOS:([A-Za-z\d]{15})$/
    end
  
    def source_use_only
      errors.add(:identifier_object_type, 'is not a Source') if identifier_object_type.present? && identifier_object_type != 'Source'
    end

    # lowercased IDs do seem to resolve correctly but it seems preferable to standardize them all to uppercase
    #   https://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=Publons&SrcAuth=Publons_CEL&DestLinkType=FullRecord&DestApp=WOS_CPL&KeyUT=WOS:a1953uA43400007
    def upcase_identifier
      self.identifier = identifier.upcase unless identifier.nil?
    end

    # TODO: add data_exists? method to check if the identifier uri resolves?
  
  end
  