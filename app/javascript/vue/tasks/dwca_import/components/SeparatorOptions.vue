<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{
      width: '600px'
    }"
    @close="cancel"
  >
    <template #header>
      <h3>Delimiter</h3>
    </template>
    <template #body>
      <h4>Field delimiter</h4>
      <ul class="no_bullets horizontal-left-content gap-medium">
        <li
          v-for="(value, key) in FIELD_DELIMITER"
          :key="key"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="fieldDelimiter"
            />
            {{ key }}
          </label>
        </li>
        <li>
          <input
            type="text"
            v-model="customDelimiter"
          />
        </li>
      </ul>
      <h4>String delimiter</h4>
      <ul class="no_bullets horizontal-left-content gap-medium">
        <li
          v-for="item in STRING_DELIMITER"
          :key="item"
        >
          <label>
            <input
              type="radio"
              :value="item"
              v-model="stringDelimiter"
            />
            {{ item }}
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              v-model="stringDelimiter"
              :value="undefined"
            />
            None
          </label>
        </li>
      </ul>
    </template>
    <template #footer>
      <VBtn
        color="create"
        medium
        :disabled="!currentFieldSeparator"
        @click="submit"
      >
        Upload
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FIELD_DELIMITER, STRING_DELIMITER } from '../const/delimiters.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal'

const resolvePromise = ref(null)
const rejectPromise = ref(null)
const isModalVisible = ref(false)
const stringDelimiter = ref(null)
const fieldDelimiter = ref(null)
const customDelimiter = ref('')

const currentFieldSeparator = computed(() => {
  return fieldDelimiter.value === FIELD_DELIMITER.Other
    ? customDelimiter.value
    : fieldDelimiter.value
})

function show({ field, str }) {
  stringDelimiter.value = str
  fieldDelimiter.value = field
  customDelimiter.value = ''
  isModalVisible.value = true

  return new Promise((resolve, reject) => {
    resolvePromise.value = resolve
    rejectPromise.value = reject
  })
}

function submit() {
  const payload = {
    col_sep: currentFieldSeparator.value,
    quote_char: stringDelimiter.value
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
