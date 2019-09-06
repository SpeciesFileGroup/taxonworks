export default function (state, value) {
  state.taxon_name.origin_citation = value.origin_citation
  state.taxon_name.cached_html = value.cached_html
  state.taxon_name.cached_author_year = value.cached_author_year
}
