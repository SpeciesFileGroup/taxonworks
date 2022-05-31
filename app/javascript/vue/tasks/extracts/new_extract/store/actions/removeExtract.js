import { Extract } from 'routes/endpoints'
import { removeFromArray } from 'helpers/arrays'

export default ({ state, commit }, extract) => {
  Extract.destroy(extract.id)
  removeFromArray(state.recents, extract)
  TW.workbench.alert.create('Extract was successfully destroyed.', 'notice')
}
