<template>
  <div>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <VBtn
      color="primary"
      @click="() => (isModalVisible = true)"
    >
      {{ title }}
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '1280px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>{{ title }}</h3>
      </template>
      <template #body>
        <VList
          :list="list"
          project
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
import { ref, watch } from 'vue'
import { removeFromArray } from '@/helpers'
import { makeNews } from '../adapters'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VList from './List.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },

  service: {
    type: Function,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  project: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['edit'])

const isLoading = ref(false)
const isModalVisible = ref(false)
const list = ref([])

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

function updateAccess({ isPublic, index }) {
  const item = list.value[index]
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

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true
    props
      .service({})
      .then(({ body }) => {
        list.value = body.map(makeNews)
      })
      .finally(() => {
        isLoading.value = false
      })
  }
})
</script>
