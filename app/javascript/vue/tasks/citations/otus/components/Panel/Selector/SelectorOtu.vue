<template>
  <BlockLayout :warning="!store.selected.otu">
    <template #header>
      <h3>OTU</h3>
    </template>
    <template #body>
      <SmartSelectorItem
        v-if="store.selected.otu"
        :item="store.selected.otu"
        label="object_tag"
        @unset="
          () => {
            store.selected.otu = null
            store.otuCitations = []
          }
        "
      />
      <SmartSelector
        v-else
        model="otus"
        klass="otus"
        pin-section="Otus"
        :pin-type="OTU"
        :target="OTU"
        @selected="
          (otu) => {
            isModalVisible = false
            store.selected.otu = otu
            store.loadOtuCitations({ otuId: otu.id })
          }
        "
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { OTU } from '@/constants'
import { Otu } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import useStore from '../../../store/store.js'

const store = useStore()
const isModalVisible = ref(false)

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')

  if (/^\d+$/.test(otuId)) {
    Otu.find(otuId)
      .then(({ body }) => {
        store.selected.otu = body
      })
      .finally(() => (isModalVisible.value = false))
  }
})
</script>
