<template>
  <div id="cite_otus">
    <div class="flexbox gap-medium">
      <div class="flex-col gap-medium">
        <div class="flexbox">
          <div class="flexbox item item1 gap-medium">
            <PanelSelector />
          </div>
        </div>
        <PanelCitation v-if="store.selected.citation" />
      </div>
      <PanelRecent />
    </div>
  </div>
</template>
<script setup>
import { computed, onBeforeMount, watch } from 'vue'
import { Topic } from '@/routes/endpoints'
import PanelRecent from './components/Panel/Recent/PanelRecent.vue'
import PanelCitation from './components/Panel/Citation/PanelCitation.vue'
import PanelSelector from './components/Panel/Selector/PanelSelector.vue'
import useStore from './store/store.js'

const store = useStore()
const otu = computed(() => store.selected.otu)
const source = computed(() => store.selected.source)
const allSelected = computed(() => otu.value && source.value)

watch([otu, source], () => {
  store.selected.citation = null
  store.selected.citationTopics = []

  if (allSelected.value) {
    store.loadCitations({ otuId: otu.value.id, sourceId: source.value.id })
  }
})

onBeforeMount(() => {
  Topic.all().then(({ body }) => {
    store.topics = body
  })
})
</script>
