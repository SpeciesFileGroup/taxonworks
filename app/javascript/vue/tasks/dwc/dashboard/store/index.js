import { reactive } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'

const state = reactive({
  metadata: undefined,
  isLoadingMetadata: false
})

const getMetadata = async () => {
  state.isLoadingMetadata = true
  state.metadata = (await DwcOcurrence.metadata()).body.metadata
  state.isLoadingMetadata = false
}

const actions = {
  getMetadata
}

export {
  actions,
  state
}
