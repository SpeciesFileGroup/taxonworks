json.array!(@leads) do |lead|
  lead[:couplets_count] = couplets_count(lead)

  json.partial! '/leads/api/v1/attributes', lead:
end