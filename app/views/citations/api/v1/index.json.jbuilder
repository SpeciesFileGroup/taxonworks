# TODO: This is hot fix, sorting should be approached differently to make it work correctly with multi-page responses
json.array!(
  @citations
    .sort { |*a| a.map { |c| c.source.is_bibtex? ? c.source.nomenclature_date : Float::INFINITY }.reduce(:<=>) }
) do |citation|
  json.partial! '/citations/api/v1/attributes', citation: citation
end
