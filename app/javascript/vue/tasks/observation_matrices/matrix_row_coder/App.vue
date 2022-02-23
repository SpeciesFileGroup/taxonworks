<template>
  <div>
    <div class="flex-separate middle">
      <h1>Matrix row coder</h1>
      <NavigationRows
        v-if="matrixRow"
        :matrix-row="matrixRow"
        @select="loadRow"
      />
    </div>

    <NavigationMatrix
      v-if="matrixRow"
      class="margin-medium-bottom"
      :matrix-row="matrixRow"
    />
    <MatrixRowCoder :row-id="rowId" />
  </div>
</template>
<script>

import MatrixRowCoder from './MatrixRowCoder/MatrixRowCoder.vue'
import SetParam from 'helpers/setParam'
import NavigationRows from './MatrixRowCoder/Navigation/NavigationRows.vue'
import NavigationMatrix from './MatrixRowCoder/Navigation/NavigationMatrix.vue'
import { ObservationMatrix } from 'routes/endpoints'

export default {
  name: 'MatrixRowCoderApp',

  components: {
    MatrixRowCoder,
    NavigationMatrix,
    NavigationRows
  },

  data () {
    return {
      rowId: undefined,
      matrixRow: undefined,
      rowLabels: []
    }
  },

  mounted () {
    this.GetParams()
  },

  methods: {
    GetParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const rowId = urlParams.get('observation_matrix_row_id')

      if ((/^\d+$/).test(rowId)) {
        this.rowId = Number(rowId)
        this.loadRow(rowId)
      }
    },

    loadRow (rowId) {
      ObservationMatrix.row({ observation_matrix_row_id: rowId }).then(({ body }) => {
        this.matrixRow = body
        this.rowId = rowId
        SetParam('/tasks/observation_matrices/row_coder/index', 'observation_matrix_row_id', rowId)
      })
    }
  }
}
</script>
