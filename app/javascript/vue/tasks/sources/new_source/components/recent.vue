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
import TableList from '@/components/table_list'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ActionNames } from '../store/actions/actions'
import { Source } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { useStore } from 'vuex'

const emit = defineEmits(['close'])

const store = useStore()
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
  store.dispatch(ActionNames.LoadSource, source.id)
  emit('close', true)
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
