<template>
  <div class="panel">
    <progress-bar :reindex="reindexRequest"/>
    <div class="content">
      <h2>Build DwC occurrence records</h2>
      <div class="field label-above">
        <v-btn
          v-for="({ label, value }) in reindex"
          :key="label"
          class="margin-small-right"
          color="create"
          medium
          @click="runUnindexed(value)">
          {{ label }}
        </v-btn>
      </div>
      <filter-link>
        Build (or rebuild) occurrence records by filtered collection object result
      </filter-link>
    </div>
  </div>
</template>
<script setup>

import { ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import ProgressBar from './ProgressBar.vue'
import FilterLink from 'tasks/dwc/dashboard/components/FilterLink.vue'

const reindex = [
  {
    label: '10',
    value: 10
  },
  {
    label: '1k',
    value: 1000
  },
  {
    label: '2k',
    value: 2000
  },
  {
    label: '10k',
    value: 10000
  }
]

const reindexRequest = ref({})

const runUnindexed = async per => {
  reindexRequest.value = (await DwcOcurrence.createIndex({
    dwc_indexed: false,
    per
  })).body
}

</script>
