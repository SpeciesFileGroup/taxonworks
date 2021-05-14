<template>
  <table-grid
    :columns="imageColums.length + this.staticColumns"
    :column-width="{
      default: 'auto',
      0: '50px',
      1: '200px',
      2: collapseColumns.includes('otu') ? '40px' : 'auto',
      ...hideColumns
    }"
    gap="4">
    <div>
      <div class="header-cell">
        <label class="header-label">Collapse</label>
      </div>
    </div>
    <div/>
    <div v-show="existingOTUDepictions">
      <div class="header-cell">
        <label
          class="header-label cursor-pointer ellipsis"
          title="OTU depictions">
          <input
            type="checkbox"
            value="otu"
            v-model="collapseColumns">
          OTU depictions
        </label>
      </div>
    </div>
    <template v-for="(column, index) in imageColums">
      <div
        class="header-cell"
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
    <template v-for="(row, index) in rows">
      <div
        :key="row.id"
        class="observation-cell">
        <input
          type="checkbox"
          :value="index"
          v-model="collapseRows">
      </div>
      <div
        :key="`${row.id}-b`"
        class="otu-cell padding-small">
        <a
          v-html="row.row_object.object_tag"
          :href="browseOtu(row.row_object.id)"/>
      </div>
      <cell-depiction
        v-show="existingOTUDepictions"
        class="observation-cell padding-small edit-cell"
        :key="`${row.id}-c`"
        :show="!filterCell('otu', index)"
        :depictions="row.otuDepictions"/>
      <template v-for="(column, cIndex) in imageColums">
        <div
          class="observation-cell padding-small edit-cell"
          :key="`${row.id} ${column.id}`">
          <cell-component
            class="full_width"
            :column="column"
            :show="!filterCell(cIndex, index)"
            :row="row"/>
        </div>
      </template>
    </template>
  </table-grid>
</template>

<script>

import CellComponent from './Cell.vue'
import CellDepiction from './CellDepiction'
import TableGrid from 'components/layout/Table/TableGrid'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    TableGrid,
    CellComponent,
    CellDepiction
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
      return Object.assign({}, ...this.collapseColumns.map(position => ({ [position + this.staticColumns]: '40px' })))
    },

    imageColums () {
      return this.columns.filter(column => column.descriptor.type === 'Descriptor::Media')
    },

    staticColumns () {
      return this.existingOTUDepictions ? 3 : 2
    },

    existingOTUDepictions () {
      return this.rows.some(row => row.otuDepictions?.length)
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

    filterCell (cIndex, index) {
      return this.collapseColumns.includes(cIndex) || this.collapseRows.includes(index)
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
