export default function (state, value) {
  state.settings.autosave = value
  sessionStorage.setItem('task::newtaxonname::autosave', value)
}
