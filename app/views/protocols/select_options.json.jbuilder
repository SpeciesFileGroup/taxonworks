@protocols.each_key do |group|
  json.set!(group) do
    json.array! @protocols[group] do |k|
      json.partial! '/protocols/attributes', protocol: k
    end
  end
end
