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
      @close="showModal = false"
    >
      <template #header>
        <h3>Select a matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."
        />
        <pin-component
          class="button-circle"
          type="ObservationMatrix"
          @get-item="addRows($event.id)"
          section="ObservationMatrices"
        />
        <ul class="no_bullets">
          <li
            class="margin-small-bottom"
            v-for="item in matrixWithRows"
            :key="item.id"
          >
            <button
              class="button normal-input button-default"
              @click="addRows(item.id)"
            >
              {{ item.name }}
            </button>
          </li>
          <li
            class="margin-small-bottom"
            v-for="item in matrixWithoutRows"
            :key="item.id"
          >
            <button
              class="button normal-input button-submit"
              @click="addRows(item.id)"
            >
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
import { OTU } from 'constants/index.js'
import { sortArray } from 'helpers/arrays'
import extendButton from './shared/extendButton'

export default {
  mixins: [extendButton],

  watch: {
    async showModal (newVal) {
      if (newVal) {
        this.isLoading = true

        Promise.all([
          ObservationMatrix
            .all()
            .then(({ body }) => {
              this.observationMatrices = sortArray(body, 'name')
            }),

          ObservationMatrixRow
            .where({
              observation_object_id_vector: this.otuIds.join('|'),
              observation_object_type: OTU
            }).then(({ body }) => {
              this.matrixObservationRows = body
            })
        ]).then(_ => {
          this.isLoading = false
        })
      }
    }
  }
}
</script>
