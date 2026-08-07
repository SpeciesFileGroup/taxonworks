<template>
  <TableGrid
    class="full_width"
    :columns="2"
    :gap="4"
  >
    <div>
      <VTable
        :list="store.getters[GetterNames.GetMatrixRowsDynamic]"
        :matrix-id="matrixId"
        :header="['Dynamic rows', '']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        edit
        @delete="(item) => store.dispatch(ActionNames.RemoveRow, item.id)"
        @order="updateRowsOrder"
      />
      <pagination-component
        v-if="fixedRowPagination"
        :pagination="fixedRowPagination"
        @next-page="loadRowPage"
      />
      <VTable
        :list="store.getters[GetterNames.GetMatrixRows]"
        :matrix-id="matrixId"
        :header="['Rows (all)', '']"
        :filter-remove="(item) => item.cached_observation_matrix_row_item_id"
        :attributes="['observation_object_label']"
        :global-id-path="['observation_object_global_id']"
        warning-message="You are trying to delete the OTU/collection object row from the matrix. Deleting the row from the matrix, does not delete OTU/collection object itself; it does not also delete the observations on this OTU. Are you sure you want to proceed?"
        edit
        code
        @order="updateRowsOrder"
        @delete="
          (item) =>
            store.dispatch(
              ActionNames.RemoveRow,
              item.cached_observation_matrix_row_item_id
            )
        "
      />
      <pagination-component
        v-if="fixedRowPagination"
        :pagination="fixedRowPagination"
        @next-page="loadRowPage"
      />
    </div>
    <div class="full_width">
      <VTable
        :list="store.getters[GetterNames.GetMatrixColumnsDynamic]"
        :matrix-id="matrixId"
        :row="false"
        :header="['Dynamic column', '']"
        :attributes="['object_tag']"
        :global-id-path="['global_id']"
        @delete="(item) => store.dispatch(ActionNames.RemoveColumn, item.id)"
        @order="updateColumnsOrder"
      />
      <pagination-component
        v-if="fixedColumnPagination"
        :pagination="fixedColumnPagination"
        @next-page="loadColumnPage"
      />
      <VTable
        :list="store.getters[GetterNames.GetMatrixColumns]"
        :matrix-id="matrixId"
        :row="false"
        edit
        :header="['Columns (all)', '']"
        :attributes="[['descriptor', 'object_tag']]"
        :global-id-path="['descriptor', 'global_id']"
        :filter-remove="(item) => item.cached_observation_matrix_column_item_id"
        code
        @delete="
          (item) =>
            store.dispatch(
              ActionNames.RemoveColumn,
              item.cached_observation_matrix_column_item_id
            )
        "
        @order="updateColumnsOrder"
      />
      <pagination-component
        v-if="fixedColumnPagination"
        :pagination="fixedColumnPagination"
        @next-page="loadColumnPage"
      />
    </div>
  </TableGrid>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import {
  ObservationMatrixRow,
  ObservationMatrixColumn
} from '@/routes/endpoints'
import VTable from './table.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import PaginationComponent from '@/components/pagination'

const store = useStore()
const matrixId = computed(() => store.getters[GetterNames.GetMatrix].id)
const fixedRowPagination = computed(
  () => store.getters[GetterNames.GetRowFixedPagination]
)
const fixedColumnPagination = computed(
  () => store.getters[GetterNames.GetColumnFixedPagination]
)

function updateRowsOrder(ids) {
  ObservationMatrixRow.sort(ids).then(() => {
    store.dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
  })
}

function updateColumnsOrder(ids) {
  ObservationMatrixColumn.sort(ids).then(() => {
    store.dispatch(ActionNames.GetMatrixObservationColumns, {
      per: 500
    })
  })
}
function loadRowPage(event) {
  store.dispatch(ActionNames.GetMatrixObservationRows, {
    page: event.page
  })
}

function loadColumnPage(event) {
  store.dispatch(ActionNames.GetMatrixObservationColumns, {
    page: event.page
  })
}
</script>
