<template>
  <BlockLayout :warning="!store.selected.source">
    <template #header>
      <h3>Source</h3>
    </template>
    <template #body>
      <SmartSelectorItem
        v-if="store.selected.source"
        :item="store.selected.source"
        label="cached"
        @unset="
          () => {
            store.selected.source = null
            store.sourceCitations = []
          }
        "
      />
      <SmartSelector
        v-else
        model="sources"
        :target="OTU"
        pin-section="Sources"
        :pin-type="SOURCE"
        label="cached"
        autofocus
        @selected="
          (source) => {
            store.selected.source = source
            store.loadSourceCitations({ sourceId: source.id })
            isModalVisible = false
          }
        "
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { Source } from '@/routes/endpoints'
import { OTU, SOURCE } from '@/constants'
import useStore from '../../../store/store.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()
const isModalVisible = ref(false)

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const sourceId = urlParams.get('source_id')

  if (/^\d+$/.test(sourceId)) {
    Source.find(sourceId)
      .then(({ body }) => {
        store.selected.source = body
      })
      .finally(() => (isModalVisible.value = false))
  }
})
</script>
