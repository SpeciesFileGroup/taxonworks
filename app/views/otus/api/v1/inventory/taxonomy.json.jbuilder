# /app/helpers/otus/catalog_helper.rb
json.merge!(
  otu_descendants_and_synonyms(
    @otu,
    max_descendants_depth: params[:max_descendants_depth]&.to_i || Float::INFINITY,
    common_names: extend_response_with('common_names'),
    language_alpha2: ( extend_response_with('common_names') ? params[:common_name_language] : nil) )
)

if extend_response_with('common_names')
  json.common_names do
    json.array! @otu.common_names do |c|
      json.name c.name
      json.language c.language.alpha_2
    end
  end
end
