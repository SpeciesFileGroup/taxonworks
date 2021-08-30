<template>
  <h1>DwC Dashboard</h1>
  <div id="dwc-dashboard">
    <download-panel/>
    <graph-component :metadata="metadata"/>
    <reindex-panel />
  </div>
</template>
<script setup>

import { onBeforeMount, ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import GraphComponent from './components/Graph/Graph.vue'
import DownloadPanel from './components/Download/DownloadPanel.vue'
import ReindexPanel from './components/Reindex/ReindexPanel.vue'

const metadata = ref({})

onBeforeMount(async () => {
  metadata.value = (await DwcOcurrence.metadata()).body.metadata
})

</script>
<style>
  #dwc-dashboard {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1em;
  }
</style>
