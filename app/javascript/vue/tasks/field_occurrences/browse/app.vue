<template>
  <div class="flex flex-separate middle">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <h1>Browse field occurrence</h1>
    <VAutocomplete
      v-if="store.fieldOccurrence"
      class="autocomplete"
      url="/field_occurrences/autocomplete"
      placeholder="Search a field occurrence"
      param="term"
      label="label_html"
      clear-after
      @get-item="({ id }) => loadData(id)"
    />
  </div>
  <FOHeader @select="loadData" />
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <TableGrid
      :columns="ceStore.collectingEvent ? 3 : 2"
      gap="1em"
      :column-width="{
        default: 'min-content',
        0: '1fr',
        1: ceStore.collectingEvent ? '2fr' : '1fr',
        2: '1fr'
      }"
    >
      <PanelFO />
      <PanelCE />
      <ColumnThree />
    </TableGrid>
  </TableGrid>
</template>

<script setup>
import { FIELD_OCCURRENCE, COLLECTING_EVENT } from '@/constants'
import { URLParamsToJSON } from '@/helpers'
import { onBeforeMount, ref } from 'vue'

import VAutocomplete from '@/components/ui/Autocomplete.vue'
import FOHeader from './components/FOHeader.vue'
import PanelFO from './components/Panel/PanelFO.vue'
import PanelCE from './components/PanelCE/PanelCE.vue'
import ColumnThree from './components/ColumnThree.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import useFieldOccurrenceStore from './store/store.js'
import useCollectingEventStore from './store/collectingEvent.js'
import useDeterminationStore from './store/determinations.js'
import useDepictionStore from './store/depictions.js'
import useBiocurationStore from './store/biocurations.js'
import useBiologicalAssociationStore from './store/biologicalAssociations.js'
import useIdentifierStore from './store/identifiers.js'
import useConveyanceStore from './store/conveyance.js'
import { usePopstateListener } from '@/composables'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'

defineOptions({
  name: 'BrowseFieldOccurrence'
})

const store = useFieldOccurrenceStore()
const ceStore = useCollectingEventStore()
const depictionStore = useDepictionStore()
const biocurationStore = useBiocurationStore()
const determinationStore = useDeterminationStore()
const biologicalAssociationStore = useBiologicalAssociationStore()
const identifierStore = useIdentifierStore()
const conveyanceStore = useConveyanceStore()

const isLoading = ref(false)

function loadFromIdParameter() {
  const { field_occurrence_id: foId } = URLParamsToJSON(location.href)

  if (foId) {
    loadData(foId)
  }
}

async function loadData(foId) {
  const requests = []
  const args = {
    objectId: foId,
    objectType: FIELD_OCCURRENCE
  }

  try {
    isLoading.value = true
    store.$reset()
    ceStore.$reset()
    depictionStore.$reset()
    biocurationStore.$reset()
    determinationStore.$reset()
    biologicalAssociationStore.$reset()
    identifierStore.$reset()
    conveyanceStore.$reset()

    await store.load(foId)

    const ceId = store.fieldOccurrence.collecting_event_id

    setParam(RouteNames.BrowseFieldOccurrence, 'field_occurrence_id', foId)

    if (ceId) {
      requests.push(
        ceStore.load(ceId),
        identifierStore.load({
          objectId: ceId,
          objectType: COLLECTING_EVENT
        })
      )
    }

    requests.push(
      depictionStore.load(args),
      biocurationStore.load(args),
      determinationStore.load(args),
      biologicalAssociationStore.load(args),
      identifierStore.load(args),
      conveyanceStore.load(args)
    )

    Promise.all(requests).finally(() => {
      isLoading.value = false
    })
  } catch {
    TW.workbench.alert.create('No field occurrence found.', 'notice')
  }
}

onBeforeMount(loadFromIdParameter)
usePopstateListener(loadFromIdParameter)
</script>
