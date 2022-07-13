json.person do
  json.id person.id
  json.name person.cached
  json.global_id person.to_global_id.to_s
end
