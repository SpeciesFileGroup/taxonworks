<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="showModal = true"
      :disabled="!otuIds.length"
    >
      Edit image matrix
    </button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '700px' }"
      @close="showModal = false">
      <template #header>
        <h3>Select a matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <pin-component
          class="button-circle"
          type="ObservationMatrix"
          @getItem="addRows($event.id)"
          section="ObservationMatrices"/>
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
import { sortArray } from 'helpers/arrays'

export default {
  mixins: [extendButton],

  watch: {
    showModal (newVal) {
      if (newVal) {
        const promises = []
        this.isLoading = true

        promises.push(ObservationMatrix.all().then(response => { this.observationMatrices = sortArray(response.body, 'name') }))
        promises.push(ObservationMatrixRow.where({ otu_ids: this.otuIds.join('|') }).then(({ body }) => { this.matrixObservationRows = body }))

        Promise.all(promises).then(() => {
          this.isLoading = false
        })
      }
    }
  }
}
</script>
