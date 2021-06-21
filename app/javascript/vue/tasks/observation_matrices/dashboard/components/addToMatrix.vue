<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true"
      :disabled="!otuIds.length">
      Add to matrix
    </button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '600px' }"
      @close="closeModal">
      <template #header>
        <h3>Add OTUs to matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <ul class="no_bullets">
          <li
            class="margin-small-bottom"
            v-for="item in observationMatrices"
            :key="item.id">
            <button
              class="button normal-input"
              :class="[
                isAlreadyInMatrix(item.id)
                  ? 'button-default'
                  : 'button-submit'
              ]"
              @click="addRows(item.id)">
              {{ item.name }}
            </button>
          </li>
        </ul>
      </template>
    </modal-component>
  </div>
</template>

<script>

import {
  ObservationMatrixRow,
  ObservationMatrix
} from 'routes/endpoints'

import extendButton from './shared/extendButton'

export default {
  mixins: [extendButton],

  watch: {
    showModal (newVal) {
      if (newVal) {
        const promises = []
        this.isLoading = true

        promises.push(ObservationMatrix.all().then(response => { this.observationMatrices = response.body }))
        promises.push(ObservationMatrixRow.where({ otu_ids: this.otuIds.join('|') }).then(({ body }) => { this.matrixObservationRows = body }))

        Promise.all(promises).then(() => {
          this.isLoading = false
        })
      }
    }
  }
}
</script>
