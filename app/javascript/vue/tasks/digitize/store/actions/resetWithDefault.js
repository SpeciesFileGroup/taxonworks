import ActionNames from './actionNames'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import {
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants'

export default ({ dispatch, state }) => {
  const { locked } = state.settings
  const collectingEventStore = useCollectingEventStore()
  const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
  const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
  const determinationStore = useTaxonDeterminationStore()
  const biologicalAssociationStore = useBiologicalAssociationStore()
  const biocurationStore = useBiocurationStore()

  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)

  state.collection_objects = []
  state.container = undefined
  state.containerItems = []
  state.depictions = []
  state.determinations = []
  state.materialTypes = []
  state.typeSpecimens = []
  state.preparation_type_id = undefined

  if (!locked.collecting_event) {
    collectingEventStore.reset()
  }

  recordNumber.reset({
    keepNamespace: locked.recordNumber,
    increment: state.settings.incrementRecordNumber
  })

  catalogNumber.reset({
    keepNamespace: locked.identifier,
    increment: state.settings.increment
  })

  biologicalAssociationStore.reset({
    keepRecords: locked.biologicalAssociations
  })

  determinationStore.reset({
    keepRecords: locked.taxonDeterminations
  })

  biocurationStore.reset({ keepRecords: locked.settings.biocuration })

  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map((item) => ({
        ...item,
        id: undefined,
        global_id: undefined
      }))
    : []
}
