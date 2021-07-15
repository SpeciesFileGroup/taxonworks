import ActionNames from './actionNames'
export default ({ dispatch, state }) => {
  dispatch(ActionNames.NewCollectionEvent)
  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)
  dispatch(ActionNames.NewIdentifier)
  dispatch(ActionNames.NewTaxonDetermination)
  dispatch(ActionNames.NewLabel)

  state.materialTypes = []
  state.determinations = []
  state.container = undefined
  state.containerItems = []
  state.collection_objects = []
  state.depictions = []
  state.identifiers = []
  state.preparation_type_id = undefined
  state.taxon_determinations = []
}