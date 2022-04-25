export default ({ state }) => {
  state.taxon_determinations = state.settings.locked.taxonDeterminations
    ? state.taxon_determinations.map((item, index) => ({ ...item, id: undefined, global_id: undefined, position: undefined }))
    : []
}