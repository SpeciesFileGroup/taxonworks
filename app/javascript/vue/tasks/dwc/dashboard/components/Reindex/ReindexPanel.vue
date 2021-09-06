<template>
  <div class="panel content reindex__panel">
    <h2>Rebuild index</h2>
    <div class="field">
      <v-btn
        color="create"
        medium
        @click="runReindex">
        1 year
      </v-btn>
    </div>
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
    <progress-bar :reindex="reindexRequest"/>
  </div>
</template>
<script setup>

import { ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import ProgressBar from '../ProgressBar.vue'

const reindex = [
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
const props = defineProps({
  params: {
    type: Object,
    default: () => ({
      geographic_area_id: [12]
    })
  }
})

const runUnindexed = async per => {
  reindexRequest.value = (await DwcOcurrence.createIndex({
    ...props.params,
    dwc_indexed: false,
    per
  })).body
}

const runReindex = async () => {
  reindexRequest.value = (await DwcOcurrence.createIndex({ ...props.params })).body
}

</script>
<style scoped>
  .reindex__panel {
    grid-column: 2 / 3
  }
</style>
