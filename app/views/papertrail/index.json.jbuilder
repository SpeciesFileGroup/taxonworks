json.array!(@versions) do |version|
  json.partial! '/papertrail/attributes', version: version 
end

