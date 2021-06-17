<template>
  <div class="horizontal-left-content align-start">
    <div>
      <rows-table
        class="margin-medium-bottom"
        :list="rowsListDynamic"
        :matrix-id="matrixId"
        :header="['Dynamic rows', '']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        @delete="removeRow($event.id)"
        :edit="true"
        @order="updateRowsOrder"/>
      <pagination-component
        v-if="fixedRowPagination"
        @nextPage="loadRowPage"
        :pagination="fixedRowPagination"/>
      <rows-table
        :list="rowsList"
        :matrix-id="matrixId"
        :header="['Rows (all)', '']"
        :filter-remove="item => item.cached_observation_matrix_row_item_id"
        :attributes="['observation_matrix_row_object_label']"
        :global-id-path="['observation_matrix_row_object_global_id']"
        warning-message="You are trying to delete the OTU/collection object row from the matrix. Deleting the row from the matrix, does not delete OTU/collection object itself; it does not also delete the observations on this OTU. Are you sure you want to proceed?"
        @delete="removeRow($event.cached_observation_matrix_row_item_id)"
        :edit="true"
        :code="true"
        @order="updateRowsOrder"/>
      <pagination-component
        v-if="fixedRowPagination"
        @nextPage="loadRowPage"
        :pagination="fixedRowPagination"/>
    </div>
    <div class="margin-medium-left">
      <columns-table
        class="margin-medium-bottom"
        :list="columnsListDynamic"
        :matrix-id="matrixId"
        :row="false"
        :header="['Dynamic column', '']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        @delete="removeColumn($event.id)"
        @order="updateColumnsOrder"/>
      <pagination-component
        v-if="fixedColumnPagination"
        @nextPage="loadColumnPage"
        :pagination="fixedColumnPagination"/>
      <columns-table
        :list="columnsList"
        :matrix-id="matrixId"
        :row="false"
        :edit="true"
        :header="['Columns (all)', '']"
        :attributes="[['descriptor', 'object_tag']]"
        :global-id-path="['descriptor', 'global_id']"
        :filter-remove="item => item.cached_observation_matrix_column_item_id"
        @delete="removeColumn($event.cached_observation_matrix_column_item_id)"
        @order="updateColumnsOrder"/>
      <pagination-component
        v-if="fixedColumnPagination"
        @nextPage="loadColumnPage"
        :pagination="fixedColumnPagination"/>
    </div>
  </div>
</template>
<script>

import TableComponent from './table.vue'

import { SortRows, SortColumns } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import PaginationComponent from 'components/pagination'

export default {
  components: {
    RowsTable: TableComponent,
    ColumnsTable: TableComponent,
    PaginationComponent
  },
  computed: {
    matrixId () {
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
    fixedRowPagination () {
      return this.$store.getters[GetterNames.GetRowFixedPagination]
    },
    fixedColumnPagination () {
      return this.$store.getters[GetterNames.GetColumnFixedPagination]
    }
  },
  methods: {
    removeColumn (id) {
      this.$store.dispatch(ActionNames.RemoveColumn, id)
    },
    removeRow (id) {
      this.$store.dispatch(ActionNames.RemoveRow, id)
    },
    updateRowsOrder (ids) {
      SortRows(ids).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      })
    },
    updateColumnsOrder (ids) {
      SortColumns(ids).then(() => {
        this.$store.dispatch(ActionNames.GetMatrixObservationColumns, { per: 500 })
      })
    },
    loadRowPage (event) {
      this.$store.dispatch(ActionNames.GetMatrixObservationRows, { page: event.page })
    },
    loadColumnPage (event) {
      this.$store.dispatch(ActionNames.GetMatrixObservationColumns, { page: event.page })
    }
  }
}
</script>
