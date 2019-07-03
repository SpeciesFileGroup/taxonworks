<template>
  <div>
    <spinner-component
      :full-screen="true"
      :legend="('Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isSaving"/>
    <div class="flex-separate">
      <h1>Image matrix</h1>
      <ul class="context-menu">
        <li>
          <a href="/tasks/observation_matrices/observation_matrix_hub/index">Back to observation matrix hub</a>
        </li>
      </ul>
    </div>
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
    let urlParams = new URLSearchParams(window.location.search)
    let obsIdParam = urlParams.get('observation_matrix_id')
    if (/^\d+$/.test(obsIdParam)) {
      GetObservationMatrix(obsIdParam).then(response => {
        this.observationMatrix = response.body
      })
      GetMatrixObservationColumns(obsIdParam).then(response => {
        this.observationColumns = response.body
      })
      GetMatrixObservationRows(obsIdParam).then(response => {
        this.observationRows = response.body
      })
    }    
  }
}
</script>