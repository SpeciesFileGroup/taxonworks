json.array!(@protocols) do |protocol|
  json.partial! 'attributes', protocol: protocol
end
