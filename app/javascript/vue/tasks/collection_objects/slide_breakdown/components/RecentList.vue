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
        :list="items"
        :attributes="['object_tag']"
        :header="['label', '']"
        :annotator="false"
        :destroy="false"
        edit
        @edit="selectItem"
      />
    </template>
  </VModal>
</template>

<script setup>
import TableList from '@/components/table_list'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import { SledImage } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const emit = defineEmits(['close'])

const items = ref([])
const isSearching = ref(false)
const isModalVisible = ref(false)

function loadRecentItems() {
  isSearching.value = true
  SledImage.where({ per: 10, recent: true })
    .then(({ body }) => {
      items.value = body
    })
    .finally(() => {
      isSearching.value = false
    })
}

function selectItem(item) {
  emit('select', item)
}

watch(isModalVisible, (isVisible) => {
  if (isVisible) {
    loadRecentItems()
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
