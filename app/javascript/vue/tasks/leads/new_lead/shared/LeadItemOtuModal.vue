<template>
  <VModal
    v-if="modalVisible"
    @close="() => { modalVisible = false }"
    :container-style="{
      width: '600px'
    }"
  >
    <template #header>
      <h3>Select an OTU to add to the lists</h3>
    </template>
    <template #body>
      <SmartSelector
        model="otus"
        klass="otus"
        :target="OTU"
        :pin-type="OTU"
        @selected="(otu) => {
          modalVisible = false
          otuSelected(otu.id)
        }"
      />
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import { LeadItem } from '@/routes/endpoints'
import { OTU } from '@/constants'
import { useStore } from '../store/useStore.js'

const modalVisible = defineModel({
  type: Boolean,
  default: false
})

const store = useStore()

function otuSelected(otuId) {
  store.setLoading(true)
  LeadItem.addLeadItemToChildLead({
    otu_id: otuId,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Added otu to the last lead list.', 'notice')
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
}
</script>