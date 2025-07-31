<template>
  <h1>DwC Dashboard</h1>
  <div id="dwc-dashboard">
    <download-panel :params="params" />
    <download-recent />
    <healt-panel />
  </div>
</template>
<script setup>
import { provide } from 'vue'
import { state, actions } from './store/index.js'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import DownloadPanel from './components/Download/DownloadPanel.vue'
import HealtPanel from './components/Health/HealthPanel.vue'
import DownloadRecent from './components/Download/DownloadRecent.vue'

const params = URLParamsToJSON(location.href)

defineOptions({
  name: 'DwcDashboard'
})

provide('state', state)
provide('actions', actions)

actions.getMetadata()
</script>

<style>
#dwc-dashboard {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1em;
}
</style>
