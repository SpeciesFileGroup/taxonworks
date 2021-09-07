<template>
  <h2>Recent downloads</h2>
  <table>
    <thead>
      <tr>
        <th
          v-for="header in PROPERTIES"
          :key="header">
          {{ humanize(header) }}
        </th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id">
        <td
          v-for="property in PROPERTIES"
          :key="property">
          {{ item[property] }}
        </td>
        <td>
          <v-btn
            color="primary"
            medium
            :disabled="!item.ready"
            @click="downloadFile(item.file_url)"
          >
            {{
              item.ready
                ? 'Download'
                : 'Processing...'
            }}
          </v-btn>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script setup>

import { watch } from 'vue'
import { Download } from 'routes/endpoints'
import { humanize } from 'helpers/strings'
import VBtn from 'components/ui/VBtn/index.vue'

const PROPERTIES = ['name', 'description', 'expires', 'times_downloaded']
const CALL_DELAY = 5000

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['onUpdate'])

let timeout

const refreshDownloadList = () => {
  const requestDownloadProcessing = props.list
    .filter(item => !item.ready)
    .map(item => Download.find(item.id))

  Promise.all(requestDownloadProcessing).then(responses => {
    const downloadRecords = responses.map(({ body }) => body)
    const downloadReady = downloadRecords.filter(item => item.ready)

    downloadReady.forEach((record, index) => {
      if (record.ready) {
        emit('onUpdate', { index, record })
      }
    })

    if (downloadRecords.length !== downloadReady.length) {
      clearTimeout(timeout)
      timeout = setTimeout(() => refreshDownloadList(), CALL_DELAY)
    }
  })
}

const downloadFile = (url) => { window.open(url) }

watch(() => props.list, () => {
  refreshDownloadList()
}, { deep: true })

</script>
