json.array!(@collection_profiles) do |collection_profile|
  json.extract! collection_profile, :id
  json.url collection_profile_url(collection_profile, format: :json)
end
