<template>
  <div>
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

import MatrixTable from './components/MatrixTable'

export default {
  components: {
    MatrixTable
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