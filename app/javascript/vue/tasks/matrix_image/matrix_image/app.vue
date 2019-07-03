<template>
  <div>
    <spinner-component
      :full-screen="true"
      :legend="('Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isSaving"/>
    <h1>Image matrix</h1>
    <matrix-table
      :columns="observationColumns"
      :rows="observationRows"/>
  </div>
</template>

<script>

import {
    GetObservationMatrix,
    GetMatrixObservationColumns,
    GetMatrixObservationRows } from './request/resources'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from 'components/spinner.vue'
import { GetterNames } from './store/getters/getters'

export default {
  components: {
    MatrixTable,
    SpinnerComponent
  },
  computed: {
    isSaving() {
      return this.$store.getters[GetterNames.GetIsSaving]
    }
  },
  data() {
    return {
      observationMatrix: undefined,
      observationColumns: [],
      observationRows: []
    }
  },
  mounted() {
    GetObservationMatrix(16).then(response => {
      this.observationMatrix = response.body
    })
    GetMatrixObservationColumns(16).then(response => {
      this.observationColumns = response.body
    })
    GetMatrixObservationRows(16).then(response => {
      this.observationRows = response.body
    })
  }
}
</script>