<template>
  <v-btn
    class="btn-download-table"
    color="primary"
    medium
    download
    :href="downloadLink"
  >
    <span>Download table</span>
  </v-btn>
</template>
<script>

import VBtn from 'components/ui/VBtn/index.vue'
import Qs from 'qs'
import { GetterNames } from '../store/getters/getters.js'

export default {
  components: { VBtn },

  computed: {
    datasetId () {
      return this.$store.getters[GetterNames.GetDataset].id
    },

    paramsFilter () {
      return {
        ...this.$store.getters[GetterNames.GetParamsFilter],
        per: undefined
      }
    },

    downloadLink () {
      const params = Qs.stringify(this.paramsFilter, { arrayFormat: 'brackets' })

      return `/import_datasets/${this.datasetId}/dataset_records.zip?${params}`
    }
  }
}
</script>
<style scoped>
.btn-download-table {
  display: flex;
  align-items: center;
}
.btn-download-table:hover {
  color: white
}
</style>
