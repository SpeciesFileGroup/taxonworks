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
    :container-style="{ width: '800px' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Predicates</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <input
        class="margin-medium-bottom"
        ref="inputRef"
        type="text"
        placeholder="Search..."
        v-model="inputValue"
      />
      <div class="flex-wrap-row gap-small">
        <template
          v-for="item in list"
          :key="item.id"
        >
          <VBtn
            v-if="
              !inputValue.length ||
              item.name.toLowerCase().includes(inputValue.toLowerCase())
            "
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
import { ref, watch, nextTick } from 'vue'
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
const inputRef = ref(null)
const isLoading = ref(false)
const isModalVisible = ref(false)
const isDataLoaded = ref(false)
const inputValue = ref('')

const emit = defineEmits(['select'])

watch(isModalVisible, (newVal) => {
  if (newVal) {
    if (!isDataLoaded.value) {
      loadData()
    }

    nextTick(() => {
      inputRef.value.focus()
    })
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
