export default function (state, taxon) {
  state.taxon_name = Object.assign({}, state.taxon_name, taxon)
}
