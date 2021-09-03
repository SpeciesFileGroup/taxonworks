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
  </div>
</template>
<script setup>

import { DwcOcurrence } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

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

const props = defineProps({
  params: {
    type: Object,
    default: () => ({
      geographic_area_id: [49876546]
    })
  }
})

const runUnindexed = (per) => {
  DwcOcurrence.createIndex({
    ...props.params,
    dwc_indexed: false,
    per
  })
}

const runReindex = () => {
  DwcOcurrence.createIndex({ ...props.params })
}

</script>
<style scoped>
  .reindex__panel {
    grid-column: 2 / 3
  }
</style>