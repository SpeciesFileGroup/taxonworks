<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <div class="flexbox horizontal-center-content align-start">
      <div class="cleft">
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
      </div>
      <div v-if="matrix.id">
        <tables-component/>
      </div>
    </div>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix'
import TablesComponent from './components/tables/view'
import RowsFixed from './components/rows/fixed'
import columnsFixed from './components/columns/fixed'

import rowsDynamic from './components/rows/dynamic'
import columnDynamic from './components/columns/dynamic'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    NewMatrix,
    RowsFixed,
    rowsDynamic,
    TablesComponent,
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
    },
    columnList() {
      return this.$store.getters[GetterNames.GetMatrixColumns]
    },
    matrixId() {
      return this.$store.getters[GetterNames.GetMatrix].id
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
<style lang="scss">
  #vue_new_matrix_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .cleft, .cright {
      min-width: 450px;
      max-width: 450px;
      width: 400px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }
</style>
