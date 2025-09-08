<template>
  <VModal
    v-if="modalVisible"
    @close="() => { modalVisible = false }"
    :container-style="{
      width: '600px'
    }"
  >
    <template #header>
      <h3>Select OTUs to add to the lists</h3>
    </template>
    <template #body>
      <VSwitch
        v-model="selectMode"
        :options="['Select OTU', 'From a key', 'From an interactive key']"
        class="margin-medium-bottom"
      />
      <SmartSelector
        v-if="selectMode == 'Select OTU'"
        model="otus"
        klass="otus"
        :target="OTU"
        :pin-type="OTU"
        @selected="(otu) => {
          otusSelected([otu.id])
        }"
      />

      <KeyOtus
        v-if="selectMode == 'From a key'"
        :existing-otus="existingOtuIds"
        @selected="(otu_ids) => otusSelected(otu_ids)"
      />

      <InteractiveKeyOtus
        v-if="selectMode == 'From an interactive key'"
        :existing-otus="existingOtuIds"
        @selected="(rows) => otusSelected(rows)"
      />
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import useStore from '../store/leadStore.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import InteractiveKeyOtus from './interactiveKeyOtus.vue'
import KeyOtus from './KeyOtus.vue'
import { Lead, LeadItem } from '@/routes/endpoints'
import { OTU } from '@/constants'
import { computed, ref } from 'vue'

const props = defineProps({
  childIndex: {
    type: Number,
    default: null
  }
})

const modalVisible = defineModel({
  type: Boolean,
  default: false
})

const selectMode = ref(null)

const existingOtuIds = computed(() => {
  if (props.childIndex == null) {
    return []
  }

  return store.lead_item_otus.children[props.childIndex].otu_indices.map((i) => (store.lead_item_otus.parent[i].id))
})

const store = useStore()

function otusSelected(rows) {
  store.setLoading(true)
  const p1 = LeadItem.addLeadItemsToChildLead({
    otu_ids: rows.otuIds,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
    })
    .catch(() => {})

  const p2 = Lead.setObservationMatrix(store.root.id,
    { observation_matrix_id: rows.observationMatrixId })
    .then(() => {
      store.root.observation_matrix_id = rows.observationMatrixId
    })
    .catch(() => {})

  Promise.all([p1, p2])
    .then(() => {
      TW.workbench.alert.create('Added otus to the lead list; saved link to observation matrix', 'notice')
    })
    .finally(() => { store.setLoading(false) })
}
</script>