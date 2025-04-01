import ActionNames from './actionNames'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import {
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants'

export default ({ dispatch, state }) => {
  const { locked } = state.settings
  const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
  const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
  const determinationStore = useTaxonDeterminationStore()

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
  state.materialTypes = []
  state.typeSpecimens = []
  state.preparation_type_id = undefined

  if (!locked.collecting_event) {
    state.georeferences = []
  }

  recordNumber.reset({
    keepNamespace: locked.recordNumber,
    increment: state.settings.incrementRecordNumber
  })

  catalogNumber.reset({
    keepNamespace: locked.identifier,
    increment: state.settings.increment
  })

  determinationStore.reset({
    keepRecords: locked.taxonDeterminations
  })

  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map((item) => ({
        ...item,
        id: undefined,
        global_id: undefined
      }))
    : []
}
