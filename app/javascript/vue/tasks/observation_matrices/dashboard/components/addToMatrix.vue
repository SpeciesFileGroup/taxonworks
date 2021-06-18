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
              class="button normal-input button-submit"
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

import { ObservationMatrixRowItem } from 'routes/endpoints'

import extendButton from './shared/extendButton'

export default {
  mixins: [extendButton],

  methods: {
    addRows (matrixId) {
      const promises = []
      const data = this.otuIds.map(id => ({
        observation_matrix_id: matrixId,
        otu_id: id,
        type: 'ObservationMatrixRowItem::Single::Otu'
      }))

      data.forEach(row => { promises.push(ObservationMatrixRowItem.create({ observation_matrix_row_item: row })) })

      Promise.allSettled(promises).then(() => {
        TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
        this.closeModal()
      })
    },

    closeModal () {
      this.showModal = false
    }
  }
}
</script>
