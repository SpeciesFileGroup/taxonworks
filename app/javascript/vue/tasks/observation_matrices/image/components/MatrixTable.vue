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
    gap="4"
  >
    <div>
      <div class="header-cell">
        <label class="header-label">Collapse</label>
      </div>
    </div>
    <div />
    <div v-show="existingOTUDepictions">
      <div class="header-cell">
        <label
          class="header-label cursor-pointer ellipsis"
          title="OTU depictions"
        >
          <input
            type="checkbox"
            value="otu"
            v-model="collapseColumns"
          >
          OTU depictions
        </label>
      </div>
    </div>
    <template
      v-for="(column, index) in imageColums"
      :key="column.id"
    >
      <div
        class="header-cell"
        :class="{ 'collapse-cell': collapseColumns.includes(index)}"
      >
        <div class="header-cell">
          <label
            class="header-label cursor-pointer ellipsis"
            :title="column.name"
          >
            <input
              type="checkbox"
              :value="index"
              v-model="collapseColumns"
            >
            {{ column.name }}
          </label>
        </div>
      </div>
    </template>
    <template
      v-for="(row, rowIndex) in rows"
      :key="row.object.id"
    >
      <div
        class="observation-cell"
      >
        <input
          type="checkbox"
          :value="rowIndex"
          v-model="collapseRows"
        >
      </div>
      <div
        class="otu-cell padding-small"
      >
        <cell-link
          :row-object="row.object"
          :label="row.object.object_tag"
        />
      </div>
      <cell-depiction
        v-show="existingOTUDepictions"
        class="observation-cell padding-small edit-cell"
        :show="!filterCell('otu', rowIndex)"
        :depictions="row.objectDepictions || []"
        @remove-depiction="removeOtuDepiction({ rowIndex, index: $event })"
      />
      <template
        v-for="(depictions, columnIndex) in row.depictions"
        :key="`${columnIndex}-${row.object.id}`"
      >
        <cell-observation
          class="observation-cell padding-small edit-cell full_width"
          :descriptor-id="imageColums[columnIndex].id"
          :show="!filterCell(columnIndex, rowIndex)"
          :row-object="row.object"
          :depictions="depictions"
          :column-index="columnIndex"
          :row-index="rowIndex"
          @remove-depiction="removeDepiction({ rowIndex, columnIndex, index: $event })"
        />
      </template>
    </template>
  </table-grid>
</template>

<script>

import CellObservation from './CellObservation.vue'
import CellDepiction from './CellDepiction'
import TableGrid from 'components/layout/Table/TableGrid'
import CellLink from './CellLink.vue'
import { MutationNames } from '../store/mutations/mutations'
import { DESCRIPTOR_MEDIA } from 'constants/index'

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
      return this.columns.filter(column => column.type === DESCRIPTOR_MEDIA)
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

    removeDepiction ({ rowIndex, columnIndex, index }) {
      this.$store.commit(MutationNames.RemoveDepiction, {
        rowIndex,
        columnIndex,
        index
      })
    },

    removeOtuDepiction ({ rowIndex, index }) {
      this.$store.commit(MutationNames.RemoveOtuDepiction, {
        rowIndex,
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
    align-items: stretch;
    justify-content: center;
    flex-direction: column;
    background-color: white;
    box-sizing: border-box;
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
