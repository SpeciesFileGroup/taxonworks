@languages.each_key do |group|
  json.set!(group) do
    json.array! @languages[group] do |l|
      json.partial! '/languages/attributes', language: l
    end
  end
end
