<template>
  <h1>DwC Dashboard</h1>
  <div id="dwc-dashboard">
    <download-panel :params="params" />
    <graph-component :metadata="metadata" />
    <reindex-panel :params="params" />
  </div>
</template>
<script setup>

import { onBeforeMount, ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import GraphComponent from './components/Graph/GraphPanel.vue'
import DownloadPanel from './components/Download/DownloadPanel.vue'
import ReindexPanel from './components/Reindex/ReindexPanel.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const metadata = ref({})
const params = ref({})

onBeforeMount(async () => {
  params.value = URLParamsToJSON(location.href)
  metadata.value = (await DwcOcurrence.metadata()).body.metadata
})

</script>

<script>
export default {
  name: 'DwcDashboard'
}
</script>

<style>
  #dwc-dashboard {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1em;
  }
</style>
