<template>
  <div class="content-menu">
    <input type="number" placeholder="Matrix ID" v-model="initializeData.matrixId">
    <input type="number" placeholder="Otu ID" v-model="initializeData.otuId">
    <button type="button" @click="loadMatrix">Change</button>
  </div>
</template>
<script>

import Vue from 'vue'
import MatrixRowCoder from './MatrixRowCoder/MatrixRowCoder.vue'
import MatrixRowCoderRequest from './request/MatrixRowCoderRequest'
import { newStore } from './store/store'

export default {
  data: function () {
    return {
      initializeData: {
        rowId: 2,
        otuId: 121574,
        apiBase: '',
        apiParams: {
          project_id: 140,
          token: ''
        }
      }
    }
  },
  mounted() {
    this.GetParams()
  },
  methods: {
    GetParams() {
      let urlParams = new URLSearchParams(window.location.search)
      let rowId = urlParams.get('observation_matrix_row_id')

      if ((/^\d+$/).test(rowId)) {
        this.initializeData.rowId = Number(rowId)
        this.loadMatrix()
      }
    },
    loadMatrix () {
      var props = this.initializeData
      const store = newStore(new MatrixRowCoderRequest())
      console.log("Se")
      new Vue({
        el: '#matrix_row_coder',
        store,
        render: function (createElement) {
          return createElement(MatrixRowCoder, {
            props
          })
        }
      })
    }
  }
}
</script>
