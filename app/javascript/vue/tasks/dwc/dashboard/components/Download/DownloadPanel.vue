<template>
  <div class="panel content">
    <h2>Download</h2>
    <div class="field label-above">
      <v-btn
        color="create"
        medium
        @click="download()">
        All indexed
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
    <download-recent
      :list="downloadList"
      @onUpdate="setRecord"/>
  </div>
</template>
<script setup>

import DownloadRecent from './DownloadRecent.vue'
import DownloadDateButton from './DownloadDateButton.vue'
import { DwcOcurrence, Download } from 'routes/endpoints'
import { ref, onBeforeMount } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'

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

const downloadList = ref([])

const download = async (downloadParams) => {
  downloadList.value.push((await DwcOcurrence.generateDownload({ ...props.params, ...downloadParams })).body)
}

const setRecord = ({ index, record }) => {
  downloadList.value[index] = record
}

onBeforeMount(async () => {
  downloadList.value = (await Download.all()).body
})

</script>
