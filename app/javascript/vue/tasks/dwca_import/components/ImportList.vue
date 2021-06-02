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
  </div>
</template>

<script>

import { GetImports, DestroyDataset } from '../request/resources.js'
import ImportCard from './ImportCard'

export default {
  components: { ImportCard },

  data: () => ({
    imports: []
  }),

  created () {
    GetImports().then((response) => {
      this.imports = response.body
    })
  },

  methods: {
    removeDataset (dataset) {
      DestroyDataset(dataset.id).then(() => {
        const index = this.imports.findIndex(({ id }) => dataset.id === id)

        this.imports.splice(index, 1)
        TW.workbench.alert.create('Dataset was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>

<style scoped>
.import-card {
  min-width: 300px;
}
</style>
