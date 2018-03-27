<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <new-matrix/>
    <div>
      <search-component v-if="matrix.id"/>
    </div>
    <div>
      <rows-table/>
    </div>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix'
import SearchComponent from './components/smartSelector/search.vue'
import rowsTable from './components/tables/rows'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'
import { MutationNames } from './store/mutations/mutations';

export default {
  components: {
    NewMatrix,
    rowsTable,
    SearchComponent
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    },
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

