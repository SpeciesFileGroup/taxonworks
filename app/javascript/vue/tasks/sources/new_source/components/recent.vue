<template>
  <VBtn
    color="primary"
    type="button"
    medium
    @click="() => (isModalVisible = true)"
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Recent</h3>
    </template>
    <template #body>
      <VSpinner v-if="isSearching" />
      <TableList
        :list="sources"
        :attributes="['cached']"
        :header="['cached', '']"
        :annotator="false"
        :destroy="false"
        edit
        @edit="setSource"
      />
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Source } from '@/routes/endpoints'
import { useSourceStore } from '../store'
import TableList from '@/components/table_list'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useSourceStore()
const sources = ref([])
const isSearching = ref(false)
const isModalVisible = ref(false)

function getSources() {
  isSearching.value = true
  Source.where({ per: 10, recent: true })
    .then(({ body }) => {
      sources.value = body
    })
    .finally(() => {
      isSearching.value = false
    })
}

function setSource(source) {
  store.loadSource(source.id)
  isModalVisible.value = false
}

watch(isModalVisible, (isVisible) => {
  if (isVisible) {
    getSources()
  }
})
</script>

<style scoped>
:deep(.modal-container) {
  width: 500px;
}
textarea {
  height: 100px;
}
:deep(.modal-container) {
  width: 800px !important;
}
</style>
