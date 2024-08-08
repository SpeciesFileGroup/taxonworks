<template>
  <VBtn
    color="primary"
    medium
    @click="isModalVisible = true"
  >
    All
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Predicates</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <div class="flex-wrap-row gap-small">
        <template
          v-for="item in list"
          :key="item.id"
        >
          <VBtn
            v-if="!predicates.some((p) => p.id === item.id)"
            color="primary"
            @click="() => onPredicateSelected(item)"
          >
            {{ item.name }}
          </VBtn>
        </template>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { PREDICATE } from '@/constants'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineProps({
  predicates: {
    type: Array,
    required: true
  }
})

const list = ref([])
const isLoading = ref(false)
const isModalVisible = ref(false)
const isDataLoaded = ref(false)

const emit = defineEmits(['select'])

watch(isModalVisible, (newVal) => {
  if (newVal) {
    if (!isDataLoaded.value) {
      loadData()
    }
  }
})

function loadData() {
  isLoading.value = true
  ControlledVocabularyTerm.where({ type: [PREDICATE] })
    .then(({ body }) => {
      list.value = body
      isDataLoaded.value = true
    })
    .finally(() => {
      isLoading.value = false
    })
}

function onPredicateSelected({ id, name }) {
  isModalVisible.value = false
  emit('select', { id, name })
}
</script>
