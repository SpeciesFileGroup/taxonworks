json.extract! coldp_profile, :id, :title_alias, :project_id, :otu_id, :prefer_unlabelled_otu, :checklistbank, :export_interval, :created_at, :updated_at
json.url coldp_profile_url(coldp_profile, format: :json)
