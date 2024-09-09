import ActionNames from './actionNames'
import { useIdentifierStore } from '../pinia/identifiers'
import { IDENTIFIER_LOCAL_RECORD_NUMBER } from '@/constants'
import incrementIdentifier from '../../helpers/incrementIdentifier'

export default ({ dispatch, state }) => {
  const { locked } = state.settings
  const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()

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

  recordNumber.reset({
    keepNamespace: locked.recordNumber,
    increment: state.settings.incrementRecordNumber
  })

  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map((item) => ({
        ...item,
        id: undefined,
        global_id: undefined
      }))
    : []

  dispatch(ActionNames.ResetTaxonDetermination)
}
