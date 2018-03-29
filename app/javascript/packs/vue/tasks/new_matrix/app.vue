<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <new-matrix/>
    <div>
      <template v-if="matrix.id">
        <rows-view v-if="isRow"/>
      </template>
    </div>
    <div v-if="matrix.id">
      <rows-table/>
    </div>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix'
import rowsTable from './components/tables/rows'
import rowsView from './components/rows/rowsView'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'
import { MutationNames } from './store/mutations/mutations'

export default {
  components: {
    NewMatrix,
    rowsTable,
    rowsView,
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

