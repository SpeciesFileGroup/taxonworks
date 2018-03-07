json.array!(@protocol_relationships) do |protocol_relationship|
  json.partial! 'attributes', protocol_relationship: protocol_relationship
end
