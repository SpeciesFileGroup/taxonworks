<template>
  <div
    style="min-width: 0"
    class="panel content"
    v-help.section.freshnessIndex
  >
    <VSpinner v-if="useState.isLoadingMetadata" />
    <GraphIndex />
  </div>
  <div
    style="min-width: 0"
    class="panel content"
    v-help.section.freshnessVersions
  >
    <VSpinner v-if="useState.isLoadingMetadata" />
    <GraphCollectionObject />
  </div>
</template>

<script setup>
import { onBeforeMount, inject } from 'vue'
import GraphIndex from './GraphIndex.vue'
import GraphCollectionObject from './GraphCollectionObjects.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const useActions = inject('actions')
const useState = inject('state')

onBeforeMount(async () => {
  useActions.getMetadata()
})
</script>
