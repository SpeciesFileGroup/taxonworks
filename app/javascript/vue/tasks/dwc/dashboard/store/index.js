import { reactive } from 'vue'
import { DwcOcurrence } from '@/routes/endpoints'
import { removeFromArray } from '@/helpers'

const state = reactive({
  metadata: undefined,
  isLoadingMetadata: false,
  downloadList: []
})

const getMetadata = async () => {
  state.isLoadingMetadata = true
  state.metadata = (await DwcOcurrence.metadata()).body.metadata
  state.isLoadingMetadata = false
}

const setDownloadRecord = async ({ index, record }) => {
  state.downloadList[index] = record
}

const addDownloadRecord = (record) => {
  state.downloadList.unshift(record)
}

const removeDownloadFromList = (record) => {
  removeFromArray(state.downloadList, record)
}

const actions = {
  addDownloadRecord,
  getMetadata,
  setDownloadRecord,
  removeDownloadFromList
}

export { actions, state }
