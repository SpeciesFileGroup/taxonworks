<template>
  <div class="flexbox horizontal-left-content align-start">
    <div>
      <rows-table
        class="separate-left separate-right"
        :list="rowsListDynamic"
        :matrix-id="matrixId"
        :header="['Dynamic rows', 'Options']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        @delete="removeRow"
        :edit="true"
        @order="updateRowsOrder"/>
      <rows-table
        class="separate-left separate-right"
        :list="rowsList"
        :matrix-id="matrixId"
        :header="['Rows (all)', 'Options']"
        :filter-remove="(item) => { return item.hasOwnProperty('cached_observation_matrix_row_item_id') && item.cached_observation_matrix_row_item_id }"
        :attributes="['observation_matrix_row_object_label']"
        :global-id-path="['observation_matrix_row_object_global_id']"
        @delete="removeRow"
        :edit="true"
        @order="updateRowsOrder"/>
    </div>
    <div>
      <columns-table
        :list="columnsListDynamic"
        :matrix-id="matrixId"
        :header="['Dynamic column', 'Options']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        @delete="removeColumn"
        @order="updateColumnsOrder"/>
      <columns-table
        :list="columnsList"
        :matrix-id="matrixId"
        :header="['Columns (all)', 'Options']"
        :attributes="[['descriptor', 'object_tag']]"
        :global-id-path="['descriptor', 'global_id']"
        @delete="removeColumn"
        @order="updateColumnsOrder"/>
    </div>
  </div>
</template>
<script>

import { 
  default as RowsTable, 
  default as ColumnsTable 
} from './table.vue'

import { SortRows, SortColumns } from '../../request/resources'
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
    columnsListDynamic() {
      return this.$store.getters[GetterNames.GetMatrixColumnsDynamic]
    },
    rowsList() {
      return this.$store.getters[GetterNames.GetMatrixRows]
    },
    rowsListDynamic() {
      return this.$store.getters[GetterNames.GetMatrixRowsDynamic]
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