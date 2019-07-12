<template>
  <div>
    <table>
      <thead>
        <tr>
          <th/>
          <th 
            class="header-cell"
            v-for="column in columns"
            :key="column.id">
            <span
              class="header-label"
              v-html="column.descriptor.name"/>
          </th>
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
  table {
    //table-layout: fixed;
    //width: 100%;
  }
  .padding-cell {
    padding: 1em;
    vertical-align: top;
    max-width: 100px;
  }
  tbody {
    tr:hover {
      background-color: initial !important;
      border-width: 1px !important;
      td {
        margin: 0;
        border-width: 1px !important;
      }
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
  .header-label {
    transform: rotate(-30deg);
    position: absolute;
    transform-origin: 0 0;
    width: 200px;
    bottom: 0;
    left: 0;
  }
  .header-cell {
    position: relative;
    text-align: left;
  }
  thead {
    tr {
      height: 0px !important;
      background-color: transparent;
    }
    th {
      max-height: 0px !important;
      border-bottom: 1px solid #e5e5e5;
      background-color: transparent;
    }
  }
</style>
