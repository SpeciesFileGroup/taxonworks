<template>
  <div>
    <rows-table
      :list="rowsList"
      :matrix-id="matrix"
      @order="updateRowsOrder"/>
    <columns-table
      :list="columnsList"
      :matrix-id="matrix"
      @order="updateColumnsOrder"/>
  </div>
</template>
<script>

import { 
  default as RowsTable, 
  default as ColumnsTable 
} from './rows.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    RowsTable,
    ColumnsTable
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    },
    columnsList() {
      return this.$store.getters[GetterNames.GetMatrixColumns]
    },
    rowsList() {
      return this.$store.getters[GetterNames.GetMatrixRows]
    },
    matrixId() {
      return this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  methods: {
    removeColumn(column) {
      this.$store.dispatch(ActionNames.RemoveColumn, column.id)
    },
    removeRow(row) {
      this.$store.dispatch(ActionNames.RemoveRow, row.id)
    },
    updateRowsOrder() {

    },
    updateColumnsOrder() {
      
    }
  }
}
</script>