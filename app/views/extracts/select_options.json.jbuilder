@extracts.each_key do |group|
  json.set!(group) do
    json.array! @extracts[group] do |k|
      json.partial! '/extracts/attributes', protocol: k
    end
  end
end
