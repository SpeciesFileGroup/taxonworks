<template>
  <div>
    <h1
      v-if="matrixRow"
      v-html="matrixRow.observation_matrix.object_tag"/>
    <div class="content-menu">
      <input
        type="number"
        placeholder="Observation matrix row ID"
        v-model="initializeData.rowId">
      <button
        type="button"
        class="button normal-input button-default"
        :disabled="!initializeData.rowId"
        @click="loadMatrix">Change
      </button>
      <template v-if="matrixRow">
        <span> | </span>
        <button
          type="button"
          class="button normal-input button-default"
          v-if="matrixRow.hasOwnProperty('previous_row')"
          @click="initializeData.rowId = matrixRow.previous_row.id; loadMatrix()"
          v-html="matrixRow.previous_row.row_object.object_tag"/>
        <button
          type="button"
          class="button normal-input button-default"
          v-if="matrixRow.hasOwnProperty('next_row')"
          @click="initializeData.rowId = matrixRow.next_row.id; loadMatrix()"
          v-html="matrixRow.next_row.row_object.object_tag"/>
      </template>
    </div>
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
        rowId: undefined,
        otuId: 121574,
        apiBase: '',
        apiParams: {
          project_id: '',
          token: ''
        }
      },
      matrixRow: undefined
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
    getMatrix() {
      let request = new MatrixRowCoderRequest()
      request.setApi({
        apiBase: this.initializeData.apiBase,
        apiParams: this.initializeData.apiParams
      })
      request.getMatrixRow(this.initializeData.rowId).then(response => {
        this.matrixRow = response
      })
    },
    loadMatrix () {
      var props = this.initializeData
      const store = newStore(new MatrixRowCoderRequest())
      new Vue({
        el: '#matrix_row_coder',
        store,
        render: function (createElement) {
          return createElement(MatrixRowCoder, {
            props
          })
        }
      })
      this.getMatrix()
    }
  }
}
</script>
