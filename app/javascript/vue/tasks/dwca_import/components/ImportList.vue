<template>
  <div v-if="imports.length">
    <h2>Created imports</h2>
    <VPagination
      :pagination="pagination"
      @next-page="
        ({ page }) => {
          loadPage(page)
        }
      "
    />
    <div class="flex-wrap-row">
      <ImportCard
        v-for="item in imports"
        :key="item.id"
        :dataset="item"
        @onSelect="emit('onSelect', $event)"
        @onRemove="removeDataset"
      />
    </div>
    <VPagination
      :pagination="pagination"
      @next-page="
        ({ page }) => {
          loadPage(page)
        }
      "
    />
    <VSpinner
      v-if="isDeleting"
      full-screen
      legend="Destroying dataset..."
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { GetImports, DestroyDataset } from '../request/resources.js'
import { removeFromArray } from '@/helpers/arrays.js'
import { getPagination } from '@/helpers'
import VPagination from '@/components/pagination.vue'
import ImportCard from './ImportCard'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['onSelect'])

const imports = ref([])
const isDeleting = ref(false)
const pagination = ref({})

function loadPage(page) {
  GetImports({ page }).then((response) => {
    imports.value = response.body
    pagination.value = getPagination(response)
  })
}

function removeDataset(dataset) {
  isDeleting.value = true

  DestroyDataset(dataset.id)
    .then(() => {
      removeFromArray(imports.value, dataset)

      TW.workbench.alert.create('Dataset was successfully destroyed.', 'notice')
    })
    .finally(() => {
      isDeleting.value = false
    })
}

loadPage()
</script>

<style scoped>
.import-card {
  min-width: 300px;
  max-width: 300px;
}
</style>
