<template>
  <div v-if="options.length">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <VBtn
      color="primary"
      @click="() => (isModalVisible = true)"
    >
      Recent
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '1280px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Recent news</h3>
      </template>
      <template #body>
        <VSwitch
          v-if="options.length > 1"
          class="margin-medium-bottom"
          :options="options"
          v-model="currentList"
        />
        <VList
          :list="list"
          :project="currentList === LISTS.PROJECT"
          @update:public="updateAccess"
          @edit="selectItem"
          @remove="removeNews"
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { News } from '@/routes/endpoints'
import { ref, computed, watch } from 'vue'
import {
  getCurrentProjectId,
  isCurrentUserAdministrator,
  removeFromArray
} from '@/helpers'
import { makeNews } from '../adapters'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import VList from './List.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const LISTS = {
  PROJECT: 'Project',
  ADMINISTRATION: 'Administration'
}

const SERVICES = {
  [LISTS.PROJECT]: () => News.where({}),
  [LISTS.ADMINISTRATION]: () => News.administration()
}

const emit = defineEmits(['edit'])

const projectId = getCurrentProjectId()
const isAdministrator = isCurrentUserAdministrator()

const options = computed(() => [
  ...(projectId ? [LISTS.PROJECT] : []),
  ...(isAdministrator ? [LISTS.ADMINISTRATION] : [])
])

const currentList = ref(options.value[0])
const list = ref([])
const isLoading = ref(false)
const isModalVisible = ref(false)

function loadList(listType) {
  isLoading.value = true
  list.value = []

  SERVICES[listType]()
    .then(({ body }) => {
      list.value = body.map(makeNews)
    })
    .finally(() => {
      isLoading.value = false
    })
}

function removeNews(item) {
  News.destroy(item.id)
    .then(() => {
      TW.workbench.alert.create('News was successfully destroyed.', 'notice')
      removeFromArray(list.value, item)
    })
    .catch(() => {})
}

function selectItem(item) {
  emit('edit', item)
  isModalVisible.value = false
}

function updateAccess({ item, isPublic }) {
  const payload = {
    news: {
      is_public: isPublic
    }
  }

  News.update(item.id, payload)
    .then(({ body }) => {
      item.isPublic = body.is_public
      TW.workbench.alert.create('News was successfully updated.')
    })
    .catch(() => {})
}

watch(isModalVisible, (isVisible) => {
  if (isVisible) {
    loadList(currentList.value)
  }
})

watch(currentList, (listType) => {
  loadList(listType)
})
</script>
