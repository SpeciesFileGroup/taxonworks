<template>
  <div class="panel content">
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
          <th />
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

const DEFAULT_WAIT_TIME = 60000
const TIME_BY_RECORDS = {
  1000: 5000,
  10000: 15000,
  100000: 30000
}
const PROPERTIES = [
  'created_at',
  'expires',
  'total_records',
  'times_downloaded'
]

const useState = inject('state')
const useAction = inject('actions')
const timeoutDownloadIds = []

const refreshDownloadList = list => {
  const notReadyList = list.filter(item => !item.ready && !timeoutDownloadIds.includes(item.id))

  notReadyList.forEach(record => {
    const timeRequest = getTimeByTotal(record.total_records)

    timeoutDownloadIds.push(record.id)
    refreshDownloadRecord(record, timeRequest)
  })
}

const refreshDownloadRecord = async (record, timeRequest) => {
  Download.find(record.id).then(({ body }) => {
    if (body.ready) {
      const index = useState.downloadList.findIndex(item => item.id === record.id)
      const timeoutIndex = timeoutDownloadIds.findIndex(id => id === record.id)

      useAction.setDownloadRecord({ index, record: body })
      timeoutDownloadIds.splice(timeoutIndex, 1)
    } else {
      setTimeout(() => refreshDownloadRecord(record, timeRequest), timeRequest)
    }
  })
}

const getTimeByTotal = recordTotal => {
  const maxRecord = Object.keys(TIME_BY_RECORDS).find(recordCount => recordTotal < recordCount)

  return TIME_BY_RECORDS[maxRecord] || DEFAULT_WAIT_TIME
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

const downloadFile = url => { window.open(url) }

const sortByDate = list => list.sort((a, b) => {
  const dateA = new Date(a.created_at).getTime()
  const dateB = new Date(b.created_at).getTime()

  return dateB - dateA
})

watch(() => useState.downloadList, list => {
  refreshDownloadList(list)
}, { deep: true })

onBeforeMount(async () => {
  useState.downloadList = sortByDate((await Download.where({ download_type: DOWNLOAD_DWC_ARCHIVE })).body)
})

</script>
