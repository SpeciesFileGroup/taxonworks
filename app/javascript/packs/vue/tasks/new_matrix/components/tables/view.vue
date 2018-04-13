<template>
  <div>
    <div>
    <rows-table
      :list="rowsList"
      :matrix-id="matrixId"
      :attributes="['observation_matrix_row_object_label']"
      :global-id-path="['observation_matrix_row_object_global_id']"
      @delete="removeRow"
      @order="updateRowsOrder"/>
    </div>
    <columns-table
      :list="columnsList"
      :matrix-id="matrixId"
      :attributes="[['descriptor', 'name']]"
      :global-id-path="['descriptor','global_id']"
      @delete="removeColumn"
      @order="updateColumnsOrder"/>
  </div>
</template>
<script>

import { 
  default as RowsTable, 
  default as ColumnsTable 
} from './table.vue'

import { SortRows, SortColumns, RemoveRow, RemoveColumn } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    RowsTable,
    ColumnsTable
  },
  computed: {
    matrixId() {
      return this.$store.getters[GetterNames.GetMatrix].id
    },
    columnsList() {
      return this.$store.getters[GetterNames.GetMatrixColumns]
    },
    rowsList() {
      return this.$store.getters[GetterNames.GetMatrixRows]
    },
  },
  methods: {
    removeColumn(column) {
      this.$store.dispatch(ActionNames.RemoveColumn, column.id)
    },
    removeRow(row) {
      this.$store.dispatch(ActionNames.RemoveRow, row.id)
    },
    updateRowsOrder(ids) {
      SortRows(ids).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationRows, this.matrixId)
      })
    },
    updateColumnsOrder(ids) {
      SortColumns(ids).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationColumns, this.matrixId)
      })
    },
  }
}
</script>