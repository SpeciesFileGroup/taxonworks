<template>
  <div v-if="imports.length">
    <h2>Created imports</h2>
    <div class="flex-wrap-row">
      <import-card
        v-for="item in imports"
        :key="item.id"
        :dataset="item"
        @onSelect="$emit('onSelect', $event)"
        @onRemove="removeDataset"
      />
    </div>
    <v-spinner
      v-if="isDeleting"
      full-screen
      legend="Destroying dataset..."/>
  </div>
</template>

<script>

import { GetImports, DestroyDataset } from '../request/resources.js'
import ImportCard from './ImportCard'
import VSpinner from 'components/spinner.vue'

export default {
  components: {
    ImportCard,
    VSpinner
  },

  emits: ['onSelect'],

  data: () => ({
    imports: [],
    isDeleting: false
  }),

  created () {
    GetImports().then((response) => {
      this.imports = response.body
    })
  },

  methods: {
    removeDataset (dataset) {
      this.isDeleting = true

      DestroyDataset(dataset.id).then(() => {
        const index = this.imports.findIndex(({ id }) => dataset.id === id)

        this.imports.splice(index, 1)
        TW.workbench.alert.create('Dataset was successfully destroyed.', 'notice')
      }).finally(() => {
        this.isDeleting = false
      })
    }
  }
}
</script>

<style scoped>
.import-card {
  min-width: 300px;
  max-width: 300px;
}
</style>
