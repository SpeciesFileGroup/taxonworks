# app/helpers/otus/catalog_helper.rb
json.merge!(
otu_inventory_public_content(
  @otu,
  topics: [params[:topic_id]].flatten.uniq
)
