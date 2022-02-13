<template>
  <div>
    <template v-if="matrixRow">
      <h1>Matrix row coder</h1>
      <div class="flex-separate">
        <div>
          <span>Matrix: </span><b><span v-html="matrixRow.observation_matrix.object_tag"/></b>
          <a :href="`/tasks/observation_matrices/new_matrix/${matrixRow.observation_matrix.id}`">
            Edit
          </a> | 
          <a :href="`/tasks/observation_matrices/view/${matrixRow.observation_matrix.id}`">
            View
          </a>
        </div>
        <ul class="context-menu">
          <li>
            <a href="/tasks/observation_matrices/observation_matrix_hub">Observation matrix hub</a>
          </li>
        </ul>
      </div>
    </template>
    <div class="content-menu">
      <template v-if="!matrixRow">
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
      </template>
      <template v-if="matrixRow">
        <div class="flex-separate">
          <div class="separate-top separate-bottom">
            Navigate adjacent rows:
            <button
              type="button"
              class="button normal-input button-default"
              v-if="matrixRow.hasOwnProperty('previous_row')"
              @click="initializeData.rowId = matrixRow.previous_row.id; loadMatrix()"
              v-html="matrixRow.previous_row.observation_object.object_tag"/>
            <button
              type="button"
              class="button normal-input button-default"
              v-if="matrixRow.hasOwnProperty('next_row')"
              @click="initializeData.rowId = matrixRow.next_row.id; loadMatrix()"
              v-html="matrixRow.next_row.observation_object.object_tag"/>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>
<script>

import { createApp } from 'vue'
import MatrixRowCoder from './MatrixRowCoder/MatrixRowCoder.vue'
import MatrixRowCoderRequest from './request/MatrixRowCoderRequest'
import SetParam from 'helpers/setParam'
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
      matrixRow: undefined,
      app: undefined
    }
  },
  mounted() {
    this.GetParams()
  },
  methods: {
    GetParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const rowId = urlParams.get('observation_matrix_row_id')

      if ((/^\d+$/).test(rowId)) {
        this.initializeData.rowId = Number(rowId)
        this.loadMatrix()
      }
    },
    getMatrix () {
      const request = new MatrixRowCoderRequest()

      request.setApi({
        apiBase: this.initializeData.apiBase,
        apiParams: this.initializeData.apiParams
      })
      request.getMatrixRow(this.initializeData.rowId).then(response => {
        this.matrixRow = response
      })
    },
    loadMatrix () {
      const props = this.initializeData
      const store = newStore(new MatrixRowCoderRequest())
      this.app = createApp(MatrixRowCoder,
        props
      )
      this.app.use(store)
      this.app.mount('#matrix_row_coder')

      SetParam('/tasks/observation_matrices/row_coder/index', 'observation_matrix_row_id', props.rowId)
      this.getMatrix()
    }
  }
}
</script>
