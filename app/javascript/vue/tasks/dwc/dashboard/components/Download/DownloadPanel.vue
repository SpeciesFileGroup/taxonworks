<template>
  <div class="panel content">
    <h2>Download</h2>
    <span>Includes only records stored as DwC occurrences.</span>
    <div class="field label-above margin-medium-top">
      <v-btn
        color="create"
        medium
        :disabled="!downloadCount"
        @click="download()">
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
      Download by collection object filter
    </filter-link>
    <download-recent
      :list="downloadList"
      @onUpdate="setRecord"/>
  </div>
</template>
<script setup>

import { DwcOcurrence, Download } from 'routes/endpoints'
import { ref, onBeforeMount, inject, computed } from 'vue'
import { DOWNLOAD_DWC_ARCHIVE } from 'constants/index.js'
import DownloadRecent from './DownloadRecent.vue'
import DownloadDateButton from './DownloadDateButton.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import FilterLink from '../FilterLink.vue'

const DATE_BUTTONS = {
  Day: 1,
  Week: 7,
  Month: 30,
  Year: 365
}

const props = defineProps({
  params: {
    type: Object,
    default: () => ({})
  }
})

const useState = inject('state')
const downloadList = ref([])
const downloadCount = computed(() => useState?.metadata?.index?.record_total)

const download = async (downloadParams) => {
  downloadList.value.push((await DwcOcurrence.generateDownload({ ...props.params, ...downloadParams })).body)
}

const setRecord = ({ index, record }) => {
  downloadList.value[index] = record
}

onBeforeMount(async () => {
  downloadList.value = (await Download.where({ download_type: DOWNLOAD_DWC_ARCHIVE })).body
})

</script>
