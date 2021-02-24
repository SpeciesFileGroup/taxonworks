export default function ({ state }, source) {
  state.taxon_name['origin_citation_attributes'] = {
    id: (state.taxon_name.origin_citation == undefined ? null : state.taxon_name.origin_citation.id),
    source_id: source.id,
    is_original: true,
    pages: (source === undefined ? null : source.pages)
  }
}
