json.array!(@loans) do |loan|
  json.partial! 'attributes',  loan: loan
end
