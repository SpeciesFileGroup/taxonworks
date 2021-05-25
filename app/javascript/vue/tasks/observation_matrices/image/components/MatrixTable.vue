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
            :title="column.name">
            <input
              type="checkbox"
              :value="index"
              v-model="collapseColumns">
            {{ column.name }}
          </label>
        </div>
      </div>
    </template>
    <template v-for="(row, rowIndex) in rows">
      <div
        :key="row.object.id"
        class="observation-cell">
        <input
          type="checkbox"
          :value="rowIndex"
          v-model="collapseRows">
      </div>
      <div
        :key="`${row.object.id}-b`"
        class="otu-cell padding-small">
        <cell-link
          :row-object="row.object"
          :label="row.object.object_tag"
        />
      </div>
      <cell-depiction
        v-show="existingOTUDepictions"
        class="observation-cell padding-small edit-cell"
        :key="`${row.object.id}-c`"
        :show="!filterCell('otu', rowIndex)"
        :depictions="row.objectDepictions || []"/>
      <template v-for="(depictions, columnIndex) in row.depictions">
        <div
          class="observation-cell padding-small edit-cell"
          :key="`${columnIndex} ${row.object.id}`">
          <cell-observation
            class="full_width"
            :column="imageColums[columnIndex]"
            :show="!filterCell(columnIndex, rowIndex)"
            :row-object="row.object"
            :depictions="depictions"
            @addDepiction="addDepiction({ rowIndex, columnIndex, depiction: $event })"
            @removeDepiction="removeDepiction({ rowIndex, columnIndex, index: $event })"/>
        </div>
      </template>
    </template>
  </table-grid>
</template>

<script>

import CellObservation from './CellObservation.vue'
import CellDepiction from './CellDepiction'
import TableGrid from 'components/layout/Table/TableGrid'
import CellLink from './CellLink.vue'
import { RouteNames } from 'routes/routes'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    TableGrid,
    CellObservation,
    CellDepiction,
    CellLink
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
      return this.columns.filter(column => column.type === 'Descriptor::Media')
    },

    staticColumns () {
      return this.existingOTUDepictions ? 3 : 2
    },

    existingOTUDepictions () {
      return this.rows.some(row => row.objectDepictions?.length)
    }
  },

  methods: {
    reset () {
      this.collapseRows = []
      this.collapseColumns = []
    },

    collapseAll () {
      this.collapseRows = [...Array(this.rows.length).keys()]
      this.collapseColumns = ['otu', ...Array(this.columns.length).keys()]
    },

    filterCell (cIndex, index) {
      return this.collapseColumns.includes(cIndex) || this.collapseRows.includes(index)
    },

    addDepiction ({ rowIndex, columnIndex, depiction }) {
      this.$store.commit(MutationNames.AddDepiction, {
        rowIndex,
        columnIndex,
        depiction
      })
    },

    removeDepiction ({ rowIndex, columnIndex, index }) {
      this.$store.commit(MutationNames.RemoveDepiction, {
        rowIndex,
        columnIndex,
        index
      })
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
