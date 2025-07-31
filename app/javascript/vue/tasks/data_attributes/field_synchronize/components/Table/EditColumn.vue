<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{
      width: '600px'
    }"
    @close="cancel"
  >
    <template #header>
      <h3>Update column cells - {{ columnName }}</h3>
    </template>
    <template #body>
      <h4>Mode</h4>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              :value="false"
              v-model="replaceAll"
            />
            Fill empty cells
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              :value="true"
              v-model="replaceAll"
            />
            Replace all cells
          </label>
        </li>
      </ul>

      <div class="margin-medium-top">
        <label class="d-block">Value</label>
        <input
          type="text"
          v-model="text"
        />
      </div>
    </template>
    <template #footer>
      <VBtn
        color="create"
        medium
        :disabled="!text"
        @click="submit"
      >
        Upload
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal'

const replaceAll = ref(false)
const rejectPromise = ref(null)
const resolvePromise = ref(null)
const isModalVisible = ref(false)
const columnName = ref('')
const text = ref('')

function show({ title }) {
  columnName.value = title
  isModalVisible.value = true

  return new Promise((resolve, reject) => {
    resolvePromise.value = resolve
    rejectPromise.value = reject
  })
}

function submit() {
  const payload = {
    value: text.value,
    replace: replaceAll.value
  }

  isModalVisible.value = false
  resolvePromise.value(payload)
}

function cancel() {
  isModalVisible.value = false
  rejectPromise.value(false)
}

defineExpose({
  show
})
</script>
