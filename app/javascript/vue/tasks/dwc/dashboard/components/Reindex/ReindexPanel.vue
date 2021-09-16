<template>
  <div class="panel reindex__panel">
    <progress-bar
      :reindex="reindexRequest"
      @onReady="useActions.getMetadata"/>
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

import { ref, inject } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import ProgressBar from '../ProgressBar.vue'
import FilterLink from '../FilterLink.vue'

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

const props = defineProps({
  params: {
    type: Object,
    default: () => ({})
  }
})

const useActions = inject('actions')
const reindexRequest = ref({})

const runUnindexed = async per => {
  reindexRequest.value = (await DwcOcurrence.createIndex({
    ...props.params,
    dwc_indexed: false,
    per
  })).body
}

</script>
<style scoped>
  .reindex__panel {
    grid-column: 2 / 3
  }
</style>
