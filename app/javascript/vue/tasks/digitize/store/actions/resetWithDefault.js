import ActionNames from './actionNames'

export default ({ dispatch, state }) => {
  const { locked } = state.settings

  dispatch(ActionNames.NewCollectingEvent)
  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)
  dispatch(ActionNames.NewIdentifier)
  dispatch(ActionNames.NewLabel)

  state.collection_objects = []
  state.container = undefined
  state.containerItems = []
  state.depictions = []
  state.determinations = []
  state.identifiers = []
  state.materialTypes = []
  state.typeSpecimens = []
  state.preparation_type_id = undefined

  if (!locked.collecting_event) {
    state.georeferences = []
  }

  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map(item => ({ ...item, id: undefined, global_id: undefined }))
    : []

  dispatch(ActionNames.ResetTaxonDetermination)
}
