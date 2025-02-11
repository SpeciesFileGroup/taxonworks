<template>
  <div class="flex flex-separate middle">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <h1>Field occurrence</h1>
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
import { FIELD_OCCURRENCE } from '@/constants'
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
import useDepictionStore from './store/depictions.js'
import useBiocurationStore from './store/biocurations.js'

defineOptions({
  name: 'BrowseFieldOccurrence'
})

const store = useFieldOccurrenceStore()
const ceStore = useCollectingEventStore()
const depictionStore = useDepictionStore()
const biocurationStore = useBiocurationStore()
const isLoading = ref(false)

onBeforeMount(async () => {
  const { field_occurrence_id: foId } = URLParamsToJSON(location.href)

  if (foId) {
    loadData(foId)
  }
})

async function loadData(foId) {
  const requests = []
  const args = {
    objectId: foId,
    objectType: FIELD_OCCURRENCE
  }

  try {
    isLoading.value = true
    await store.load(foId)

    const ceId = store.fieldOccurrence.collecting_event_id

    if (ceId) {
      requests.push(ceStore.load(ceId))
    }

    requests.push(depictionStore.load(args), biocurationStore.load(args))

    Promise.all(requests).finally(() => {
      isLoading.value = false
    })
  } catch {
    TW.workbench.alert.create('No field occurrence found.', 'notice')
  }
}
</script>
