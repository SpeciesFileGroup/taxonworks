<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <new-matrix/>
    <div
      v-if="matrix.id"
      class="separate-top">
      <rows-view v-if="isRow"/>
      <columns-view v-else/>
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
import RowsView from './components/rows/rowsView'
import columnsView from './components/columns/columnsView'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    NewMatrix,
    RowsTable,
    RowsView,
    ColumnsTable,
    columnsView
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    },
    isRow() {
      return (this.$store.getters[GetterNames.GetMatrixView] == 'row' ? true : false) 
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

