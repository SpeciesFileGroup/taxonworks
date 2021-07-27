<template>
  <spinner-component
    v-if="state.isUpdating"
    full-screen
  />
  <div>
    <label>
      <strong>Is public: </strong>
      <input
        v-model="state.isPublic"
        type="checkbox">
    </label>
    <div class="horizontal-left-content margin-medium-top">
      <v-btn
        color="update"
        target="_blank"
        medium
        :disabled="state.isUpdating"
        @click="updateDownload"
      >
        Update
      </v-btn>
      <div class="margin-small-left">
        <v-btn
          color="primary"
          :href="`/downloads/${downloadId}/file`"
          target="_blank"
          medium
        >
          Download
        </v-btn>
      </div>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { reactive } from 'vue'
import { Download } from 'routes/endpoints'

export default {
  name: 'Download',

  components: {
    SpinnerComponent,
    VBtn
  },

  props: {
    isPublic: {
      type: Boolean,
      default: false
    },

    downloadId: {
      type: String
    }
  },

  setup (props) {
    const state = reactive({
      isUpdating: false,
      isPublic: props.isPublic
    })

    const updateDownload = () => {
      const download = {
        is_public: state.isPublic
      }

      state.isUpdating = true
      Download.update(props.downloadId, { download }).then(_ => {
        state.isUpdating = false
      })
    }

    return {
      state,
      updateDownload
    }
  }
}
</script>
