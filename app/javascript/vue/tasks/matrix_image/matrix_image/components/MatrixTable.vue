<template>
  <table-grid
    :columns="columns.length + 2"
    :column-width="{
      default: 'auto',
      0: '50px',
      1: '200px',
      ...hideColumns
    }"
    gap="4">
    <div>
      <div class="header-cell">
        <label class="header-label">Collapse</label>
      </div>
    </div>
    <div/>
    <template v-for="(column, index) in columns">
      <div
        class="header-cell"
        v-if="column.descriptor.type == 'Descriptor::Media'"
        :key="column.id"
        :class="{ 'collapse-cell': collapseColumns.includes(index)}">
        <div class="header-cell">
          <label
            class="header-label cursor-pointer ellipsis"
            :title="column.descriptor.name">
            <input
              type="checkbox"
              :value="index"
              v-model="collapseColumns">
            {{ column.descriptor.name }}
          </label>
        </div>
      </div>
    </template>

    <template v-for="(row, rIndex) in rows">
      <div
        :key="row.id"
        class="observation-cell">
        <input
          type="checkbox"
          :value="row.id"
          :checked="!collapseRows.includes(row.id)"
          v-model="collapseRows">
      </div>
      <div
        :key="`${row.id}-b`"
        class="otu-cell padding-small">
        <a
          v-html="row.row_object.object_tag"
          :href="browseOtu(row.row_object.id)"/>
      </div>
      <div
        v-for="(column, cIndex) in columns"
        class="observation-cell padding-small edit-cell"
        :key="`${row.id} ${column.id}`">
        <cell-component
          v-if="column.descriptor.type == 'Descriptor::Media'"
          class="full_width"
          :index="rIndex + cIndex"
          :column="column"
          :show="!filterCell(cIndex, row.id)"
          :row="row"/>
      </div>
    </template>
  </table-grid>
</template>

<script>

import CellComponent from './Cell.vue'
import TableGrid from 'components/layout/Table/TableGrid'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    TableGrid,
    CellComponent
  },

  props: {
    rows: {
      type: Array,
      default: () => ([])
    },
    columns: {
      type: Array,
      default: () => ([])
    }
  },

  data () {
    return {
      collapseRows: [],
      collapseColumns: []
    }
  },

  computed: {
    hideColumns () {
      return Object.assign({}, ...this.collapseColumns.map(position => ({ [position + 2]: '40px' })))
    }
  },

  methods: {
    browseOtu (id) {
      return `${RouteNames.BrowseOtu}?otu_id=${id}`
    },

    reset () {
      this.collapseRows = []
      this.collapseColumns = []
    },

    collapseAll () {
      this.collapseRows = this.rows.map(row => row.id)
      this.collapseColumns = this.columns.map(column => column.id)
    },

    filterCell (columnId, rowId) {
      return this.collapseColumns.includes(columnId) || this.collapseRows.includes(rowId)
    }
  }
}
</script>

<style lang="scss">
#vue-matrix-image {
  .observation-cell {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    background-color: white;
  }

  .otu-cell {
    display: flex;
    align-items: center;
    justify-content: left;
    background-color: white;
  }

  .header-label {
    transform: rotate(-30deg);
    position: absolute;
    transform-origin: 0 0;
    width: 150px;
    bottom: 0;
    left: 0;
  }

  .edit-cell {
    justify-content: start;
  }

  .header-cell {
    position: relative;
    text-align: left;
  }

  .otu_tag_taxon_name {
    white-space: normal
  }

  .ellipsis {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}
</style>
