<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <new-matrix/>
    <div
      v-if="matrix.id"
      class="separate-top">
      <template v-if="isFixed">
        <rows-fixed v-if="isRow"/>
        <columns-fixed v-else/>
      </template>
      <template v-else>
        <rows-dynamic v-if="isRow"/>
        <column-dynamic v-else/>
      </template>
    </div>
    <div v-if="matrix.id">
      <rows-table/>
      <columns-table/>
    </div>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix'
import RowsTable from './components/tables/rows'
import ColumnsTable from './components/tables/columns'
import RowsFixed from './components/rows/fixed'
import columnsFixed from './components/columns/fixed'

import rowsDynamic from './components/rows/dynamic'
import columnDynamic from './components/columns/dynamic'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    NewMatrix,
    RowsTable,
    RowsFixed,
    rowsDynamic,
    ColumnsTable,
    columnsFixed,
    columnDynamic
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    },
    isRow() {
      return (this.$store.getters[GetterNames.GetMatrixView] == 'row' ? true : false) 
    },
    isFixed() {
      return (this.$store.getters[GetterNames.GetMatrixMode] == 'fixed' ? true : false)
    }
  },
  data() {
    return {
      loading: false
    }
  },
  mounted() {
    let that = this
    let matrixId = location.pathname.split('/')[4]

    if (/^\d+$/.test(matrixId)) {
      that.loading = true
      that.$store.dispatch(ActionNames.LoadMatrix, matrixId).then(function () {
        that.loading = false
      }, () => {
        that.loading = false
      })
    }
  },
  methods: {
  }
}

</script>

