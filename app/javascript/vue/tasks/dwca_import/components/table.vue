<template>
  <table class="position-relative">
    <thead>
      <tr>
        <th
          class="position-sticky">
          Status
        </th>
        <th
          class="position-sticky"
          v-for="(item, index) in table.headers"
          :key="index">
          <div class="flex-separate middle">
            <span>{{ item }}</span>
            <column-filter
              class="margin-medium-left"
              :field="item"/>
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <row-component
        v-for="(row, index) in table.rows"
        class="contextMenuCells"
        :class="{ 'even': (index % 2 == 0) }"
        :id="row.id"
        :row="row"
        :import-id="importId"
        :headers="table.headers"/>
    </tbody>
  </table>
</template>

<script>

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'

export default {
  components: {
    RowComponent,
    ColumnFilter
  },
  props: {
    table: {
      type: Object,
      required: true
    },
    importId: {
      type: [String, Number],
      required: true
    }
  }
}
</script>

<style scoped>
  th {
    top: 0
  }
</style>
