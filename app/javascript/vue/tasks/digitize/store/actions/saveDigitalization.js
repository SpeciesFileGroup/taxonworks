import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { EVENT_SMART_SELECTOR_UPDATE } from '@/constants/index.js'
import { CollectionObject } from '@/routes/endpoints'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations'
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

function makeContainerArgs(id) {
  return {
    objectId: id,
    objectType: CONTAINER
  }
}

function makeCOArgs(id) {
  return {
    objectId: id,
    objectType: COLLECTION_OBJECT
  }
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
    const biologicalAssociationStore = useBiologicalAssociationStore()

    state.settings.saving = true
    if (collectingEventStore.isUnsaved) {
      await collectingEventStore.save()
    }

    const { body } = await dispatch(
      ActionNames.SaveCollectionObject,
      state.collection_object
    )

    const coCreated = body
    const payload = state.container
      ? makeContainerArgs(state.container.id)
      : makeCOArgs(coCreated.id)

    commit(MutationNames.SetCollectionObject, coCreated)
    commit(MutationNames.AddCollectionObject, coCreated)

    const actions = [
      dispatch(ActionNames.SaveTypeMaterial),
      dispatch(ActionNames.SaveCOCitations),
      recordNumber.save(payload),
      catalogNumber.save(payload),
      determinationStore.save(makeCOArgs(coCreated.id)),
      biologicalAssociationStore.save(makeCOArgs(coCreated.id))
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
    }

    if (allSaved) {
      TW.workbench.alert.create(
        'All records were successfully saved.',
        'notice'
      )
      state.settings.lastSave = Date.now()
    }

    updateSmartSelectors()
    state.settings.saving = false
    return true
  } catch {
    state.settings.saving = false
  }
}
