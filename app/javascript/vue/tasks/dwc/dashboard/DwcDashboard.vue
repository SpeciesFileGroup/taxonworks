<template>
  <h1>DwC Dashboard</h1>
  <div id="dwc-dashboard">
    <download-panel :params="params" />
    <graph-component />
    <download-recent />
    <reindex-panel :params="params" />
    <collector-table />
  </div>
</template>
<script setup>

import { provide } from 'vue'
import { state, actions } from './store/index.js'
import GraphComponent from './components/Graph/GraphPanel.vue'
import DownloadPanel from './components/Download/DownloadPanel.vue'
import ReindexPanel from './components/Reindex/ReindexPanel.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import CollectorTable from './components/Collector/CollectorTable.vue'
import DownloadRecent from './components/Download/DownloadRecent.vue'

const params = URLParamsToJSON(location.href)

provide('state', state)
provide('actions', actions)

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
