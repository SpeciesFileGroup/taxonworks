json.extract! attribution, :id, :copyright_year, :license, :created_at, :updated_at
json.url attribution_url(attribution, format: :json)

json.partial! '/shared/data/all/metadata', object: attribution

json.attribution_creators do |a|
  a.array! attribution.attribution_creators, partial: '/shared/data/all/metadata', as: :object
end

json.attribution_editors do |a|
  a.array! attribution.attribution_creators, partial: '/shared/data/all/metadata', as: :object
end

json.attribution_owners do |a|
  a.array! attribution.attribution_creators, partial: '/shared/data/all/metadata', as: :object
end
