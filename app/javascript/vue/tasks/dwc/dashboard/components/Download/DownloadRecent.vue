<template>
  <h2>Recently created DwC Archives</h2>
  <table>
    <thead>
      <tr>
        <th
          v-for="header in PROPERTIES"
          :key="header">
          {{ humanize(header) }}
        </th>
        <th>Is public</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, index) in list"
        :key="item.id">
        <td
          v-for="property in PROPERTIES"
          :key="property">
          {{ item[property] }}
        </td>
        <td>
          <input
            type="checkbox"
            :checked="item.is_public"
            @click="setIsPublic(item, index)"
          >
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

const CALL_DELAY = 5000
const PROPERTIES = [
  'created_at',
  'expires',
  'total_records',
  'times_downloaded'
]

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

    downloadReady.forEach(record => {
      if (record.ready) {
        const index = props.list.findIndex(item => item.id === record.id)

        emit('onUpdate', { index, record })
      }
    })

    if (downloadRecords.length !== downloadReady.length) {
      timeout = setTimeout(() => refreshDownloadList(), CALL_DELAY)
    }
  })
}

const setIsPublic = ({ id, is_public }, index) => {
  const download = {
    id,
    is_public: !is_public
  }

  Download.update(id, { download }).then(({ body }) => {
    emit('onUpdate', {
      index,
      record: body
    })
  })
}

const downloadFile = (url) => { window.open(url) }

watch(() => props.list, () => {
  clearTimeout(timeout)
  refreshDownloadList()
}, { deep: true })

</script>
