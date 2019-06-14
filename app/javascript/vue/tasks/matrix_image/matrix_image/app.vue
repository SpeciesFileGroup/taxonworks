<template>
  <div>
    <h1>Image matrix</h1>
  </div>
</template>

<script>

import {
    GetObservationMatrix,
    GetMatrixObservationColumns,
    GetMatrixObservationRows } from './request/resources'

export default {
  data() {
    return {
      observationMatrix: undefined
    }
  },
  mounted() {
    GetObservationMatrix(16).then(response => {
      this.observationMatrix = response.body
    })
  }
}
</script>