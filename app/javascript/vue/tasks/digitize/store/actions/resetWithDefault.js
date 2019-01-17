import ActionNames from './actionNames'
export default function({ dispatch, state }) {
  dispatch(ActionNames.NewCollectionEvent)
  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)
  dispatch(ActionNames.NewIdentifier)
  dispatch(ActionNames.NewTaxonDetermination)
  
  state.materialTypes = [],
  state.determinations = [],
  state.container = undefined,
  state.containerItems = [],
  state.collection_objects = [],
  state.depictions = [],
  state.identifiers = [],
  state.preparation_type_id = undefined,
  state.taxon_determinations = []
}