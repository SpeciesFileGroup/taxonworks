<template>
  <div
    class="panel content"
    v-help.section.freshnessIndex>
    <spinner-component v-if="useState.isLoadingMetadata"/>
    <graph-index :metadata="metadata"/>
  </div>
  <div
    class="panel content"
    v-help.section.freshnessVersions>
    <spinner-component v-if="useState.isLoadingMetadata"/>
    <graph-collection-object />
  </div>
</template>

<script setup>

import { onBeforeMount, inject } from 'vue'
import GraphIndex from './GraphIndex.vue'
import GraphCollectionObject from './GraphCollectionObjects.vue'
import SpinnerComponent from 'components/spinner.vue'

const useActions = inject('actions')
const useState = inject('state')

onBeforeMount(async () => {
  useActions.getMetadata()
})

</script>
