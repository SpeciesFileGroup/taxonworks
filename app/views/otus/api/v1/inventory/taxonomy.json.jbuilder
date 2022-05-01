# /app/helpers/otus/catalog_helper.rb
json.merge!(
  otu_descendants_and_synonyms(
    @otu,
    common_names: extend_response_with('common_names'),
    langage_alpha2: ( extend_response_with('common_names') ? params[:common_name_language] : nil) )
)
