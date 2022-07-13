# /app/helpers/otus/catalog_helper.rb
json.merge!(
  otu_descendants_and_synonyms(
    @otu,
    max_descendants_depth: params[:max_descendants_depth]&.to_i || Float::INFINITY,
    common_names: extend_response_with('common_names'),
    langage_alpha2: ( extend_response_with('common_names') ? params[:common_name_language] : nil) )
)
