import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { EVENT_SMART_SELECTOR_UPDATE } from '@/constants/index.js'
import { CollectionObject } from '@/routes/endpoints'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import {
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  COLLECTION_OBJECT,
  CONTAINER
} from '@/constants/index.js'

const updateSmartSelectors = () => {
  const event = new CustomEvent(EVENT_SMART_SELECTOR_UPDATE)
  document.dispatchEvent(event)
}

export default async (
  { commit, dispatch, state },
  { resetAfter = false } = {}
) => {
  try {
    const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
    const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
    const determinationStore = useTaxonDeterminationStore()
    const collectingEventStore = useCollectingEventStore()

    state.settings.saving = true
    if (collectingEventStore.collectingEvent.isUnsaved) {
      await collectingEventStore.save()
    }

    const { body } = await dispatch(
      ActionNames.SaveCollectionObject,
      state.collection_object
    )

    const coCreated = body
    const payload = {
      objectId: state.container ? state.container.id : coCreated.id,
      objectType: state.container ? CONTAINER : COLLECTION_OBJECT
    }

    commit(MutationNames.SetCollectionObject, coCreated)
    commit(MutationNames.AddCollectionObject, coCreated)

    const actions = [
      dispatch(ActionNames.SaveTypeMaterial),
      dispatch(ActionNames.SaveCOCitations),
      dispatch(ActionNames.SaveBiologicalAssociations),
      recordNumber.save(payload),
      catalogNumber.save(payload),
      determinationStore.save({
        objectId: coCreated.id,
        objectType: COLLECTION_OBJECT
      })
    ]

    const promises = await Promise.allSettled(actions)

    const allSaved = promises.every((item) => item.status == 'fulfilled')

    if (resetAfter && allSaved) {
      dispatch(ActionNames.ResetWithDefault)
    } else {
      await dispatch(ActionNames.LoadSoftValidations)
      await CollectionObject.find(state.collection_object.id, {
        extend: ['dwc_occurrence']
      }).then(({ body }) => {
        state.collection_object.object_tag = body.object_tag
        state.collection_object.dwc_occurrence = body.dwc_occurrence
      })

      state.settings.lastSave = Date.now()
    }

    if (allSaved) {
      TW.workbench.alert.create(
        'All records were successfully saved.',
        'notice'
      )
    }

    updateSmartSelectors()
    state.settings.saving = false
    return true
  } catch {
    state.settings.saving = false
  }
}
