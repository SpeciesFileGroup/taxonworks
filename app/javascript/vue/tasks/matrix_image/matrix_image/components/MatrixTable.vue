<template>
  <div>
    <table>
      <thead>
        <tr>
          <th>Rows/columns</th>
          <th 
            v-for="column in columns"
            :key="column.id"
            v-html="column.descriptor.name"/>
        </tr>
      </thead>
      <tbody>
        <tr
          class="row-cell"
          v-for="(row, rIndex) in rows">
          <td v-html="row.row_object.object_tag"/>
          <td
            class="padding-cell"
            v-for="(column, cIndex) in columns"
            :key="column.id">
            <cell-component 
              :index="rIndex + cIndex"
              :column="column"
              :row="row"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import CellComponent from './Cell.vue'

export default {
  components: {
    CellComponent
  },
  props: {
    rows: {
      type: Array,
      default: () => { return [] }
    },
    columns: {
      type: Array,
      default: () => { return [] }
    }
  }
}
</script>

<style scoped lang="scss">
  .padding-cell {
    padding: 1em
  }
  tr:hover {
    background-color: initial !important;
    border-width: 1px !important;
    td {
      border-width: 1px !important;
    }
  }

  .row-cell { 
    td {
      border-bottom: 1px solid #e5e5e5;
      border-left: 1px solid #e5e5e5;
    }
  }
  .row-cell:hover {
    background-color: #FFFFFF;
    td {
      border-left:1px solid #e5e5e5;
    }
  }
</style>
