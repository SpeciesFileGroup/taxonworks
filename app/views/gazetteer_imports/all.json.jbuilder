json.array!(@import_jobs) do |j|
  json.partial! 'attributes', gazetteer_import: j
end