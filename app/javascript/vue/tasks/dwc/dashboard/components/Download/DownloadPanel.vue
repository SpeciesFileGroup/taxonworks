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
        class="margin-small-right capitalize"
        :key="label"
        :label="label"
        :days="days"
        :count="getTotal(label)"
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
  day: 1,
  week: 7,
  month: 30,
  year: 365
}

const useAction = inject('actions')
const useState = inject('state')
const downloadCount = computed(() => useState?.metadata?.index?.record_total)

const getTotal = date => useState?.metadata?.index.freshness[`one_${date}`]

const download = async downloadParams => {
  useAction.addDownloadRecord((await DwcOcurrence.generateDownload({ ...downloadParams, dwc_indexed: true })).body)
}

</script>
