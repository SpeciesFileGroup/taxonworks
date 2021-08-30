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
        v-for="(days, label) in dateButtons"
        class="margin-small-right"
        :key="label"
        :label="label"
        :days="days"
        @onDate="download"
      >
        {{ label }}
      </download-date-button>
    </div>
    <download-recent/>
  </div>
</template>
<script setup>

import DownloadRecent from './DownloadRecent.vue'
import DownloadDateButton from './DownloadDateButton.vue'
import { DwcOcurrence } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

const dateButtons = {
  Day: 1,
  Week: 7,
  Month: 30,
  Year: 365
}

const download = (params) => {
  DwcOcurrence.generateDownload(params)
}

</script>
