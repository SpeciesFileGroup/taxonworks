<template>
  <div>
    <table>
      <thead>
        <tr>
          <th class="checkbox-cell">
            <span class="header-label">Collapse</span>
          </th>
          <th class="object-cell"/>
          <th 
            class="header-cell"
            :class="{ 'collapse-cell': collapseColumns.includes(column.id)}"
            v-for="column in columns"
            :key="column.id">
            <label class="header-label">
              <input
                type="checkbox"
                :value="column.id"
                v-model="collapseColumns"
              />
              {{ column.descriptor.name }}
            </label>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="row-cell"
          v-for="(row, rIndex) in rows">
          <td class="checkbox-cell">
            <input
              type="checkbox"
              :value="row.id"
              :checked="!collapseRows.includes(row.id)"
              v-model="collapseRows"/>
          </td>
          <td
            class="object-cell"
            v-html="row.row_object.object_tag"/>
          <template>
            <template v-for="(column, cIndex) in columns">
              <td
                v-if="!collapseColumns.includes(column.id) && !collapseRows.includes(row.id)"
                class="padding-cell"
                :key="column.id">
                <cell-component 
                  :index="rIndex + cIndex"
                  :column="column"
                  :row="row"/>
              </td>
              <td
                v-else
                :key="column.id"
                class="collapse-cell"/>
            </template>
          </template>
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
  },
  data() {
    return {
      collapseRows: [],
      collapseColumns: []
    }
  },
  methods: {
    reset() {
      this.collapseRows = []
      this.collapseColumns = []
    },
    collapseAll() {
      this.collapseRows = this.rows.map(row => { return row.id })
      this.collapseColumns = this.columns.map(column => { return column.id })
    }
  }
}
</script>

<style scoped lang="scss">
  table {
    max-width: 100vh;
    max-height: calc(100vh - 170px);
    font-size: 12px;
  }
  .padding-cell {
    padding: 1em;
    vertical-align: top;
    max-width: 100px;
    min-width: 100px;
    font-size: 12px;
  }

  .collapse-cell {
    max-width: 50px !important;
    min-width: 28px !important;
    padding: 0px;
  }

  .checkbox-cell {
    position: relative;
    min-width: 18px;
    max-width: 18px;
    font-size: 12px;
  }

  .object-cell {
    font-size: 12px;
    min-width: 200px !important;
    max-width: 200px !important;
  }

  tbody {
    display: block;
    max-height: calc(100vh - 200px);
    overflow-y: auto;
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
    min-width: 100px;
    position: relative;
    text-align: left;
  }
  thead {
    display: block;
    tr {
      height: 0px !important;
      min-height: 0px !important;
      background-color: transparent;
    }
    th {
      max-height: 0px !important;
      min-height: 0px !important;
      border-left: 1px solid transparent;
      border-bottom: 1px solid #e5e5e5;
      background-color: transparent;
    }
  }
</style>
