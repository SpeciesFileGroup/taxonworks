<template>
  <div class="panel content">
    <h2>Download Darwin Core Archive</h2>
    <i>Includes only records stored as DwC occurrences.</i>
    <div class="field label-above margin-medium-top">
      <v-btn
        color="create"
        medium
        :disabled="!downloadCount"
        @click="download({ per: downloadCount })">
        All ({{ downloadCount }})
      </v-btn>
    </div>
    <div class="field label-above">
      <label>Past</label>
      <download-date-button
        v-for="(days, label) in DATE_BUTTONS"
        class="margin-small-right"
        :key="label"
        :label="label"
        :days="days"
        @onDate="download"
      >
        {{ label }}
      </download-date-button>
    </div>
    <filter-link>
      Create DwC Archive by filtered collection object result
    </filter-link>
  </div>
</template>
<script setup>

import { DwcOcurrence } from 'routes/endpoints'
import { inject, computed } from 'vue'
import DownloadDateButton from './DownloadDateButton.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import FilterLink from '../FilterLink.vue'

const DATE_BUTTONS = {
  Day: 1,
  Week: 7,
  Month: 30,
  Year: 365
}

const useAction = inject('actions')
const useState = inject('state')
const downloadCount = computed(() => useState?.metadata?.index?.record_total)

const download = async downloadParams => {
  useAction.addDownloadRecord((await DwcOcurrence.generateDownload({ ...downloadParams, dwc_indexed: true })).body)
}

</script>
