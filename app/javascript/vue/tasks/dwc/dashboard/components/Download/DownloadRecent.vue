<template>
  <div class="panel content download-table">
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
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in useState.downloadList"
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
            <radial-navigation :global-id="item.global_id"/>
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
  </div>
</template>
<script setup>

import { inject, onBeforeMount, watch } from 'vue'
import { DOWNLOAD_DWC_ARCHIVE } from 'constants/index.js'
import { Download } from 'routes/endpoints'
import { humanize } from 'helpers/strings'
import VBtn from 'components/ui/VBtn/index.vue'
import RadialNavigation from 'components/radials/navigation/radial.vue'

const CALL_DELAY = 5000
const PROPERTIES = [
  'created_at',
  'expires',
  'total_records',
  'times_downloaded'
]

const emit = defineEmits(['onUpdate'])
const useState = inject('state')
const useAction = inject('actions')

let timeout

const refreshDownloadList = () => {
  const requestDownloadProcessing = useState.downloadList
    .filter(item => !item.ready)
    .map(item => Download.find(item.id))

  Promise.all(requestDownloadProcessing).then(responses => {
    const downloadRecords = responses.map(({ body }) => body)
    const downloadReady = downloadRecords.filter(item => item.ready)

    downloadReady.forEach(record => {
      if (record.ready) {
        const index = useState.downloadList.findIndex(item => item.id === record.id)
        useAction.setDownloadRecord({ index, record })
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
    useAction.setDownloadRecord({
      index,
      record: body
    })
  })
}

const downloadFile = (url) => { window.open(url) }

const sortByDate = (list) => list.sort((a, b) => {
  const dateA = new Date(a.created_at).getTime()
  const dateB = new Date(b.created_at).getTime()

  return dateB - dateA
})

watch(() => useState.downloadList, () => {
  clearTimeout(timeout)
  refreshDownloadList()
}, { deep: true })

onBeforeMount(async () => {
  useState.downloadList = sortByDate((await Download.where({ download_type: DOWNLOAD_DWC_ARCHIVE })).body)
})

</script>
<style scoped>
  .download-table {
    grid-column: 1/3;
  }
</style>