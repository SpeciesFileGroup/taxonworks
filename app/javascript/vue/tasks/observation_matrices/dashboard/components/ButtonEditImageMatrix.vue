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
      :container-style="{ width: '600px' }"
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
          @getItem="openImageMatrix($event.id)"
          section="ObservationMatrices"/>
        <ul class="no_bullets">
          <li
            class="margin-small-bottom"
            v-for="item in observationMatrices"
            :key="item.id">
            <button
              class="button normal-input button-default"
              @click="openImageMatrix(item.id)">
              {{ item.name }}
            </button>
          </li>
        </ul>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'
import extendButton from './shared/extendButton'

export default {
  mixins: [extendButton],

  methods: {
    openImageMatrix (matrixId) {
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${matrixId}&otu_filter=${this.otuIds.join('|')}`, '_blank')
      this.showModal = false
    }
  }
}
</script>
