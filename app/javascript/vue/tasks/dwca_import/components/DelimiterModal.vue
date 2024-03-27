<template>
  <VModal>
    <template #header>
      <h3>Delimiter</h3>
    </template>
    <template #body>
      <h4>Field delimiter</h4>
      <ul class="no_bullets">
        <li
          v-for="(value, key) in FIELD_DELIMITER"
          :key="key"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="delimiters.field"
            />
            {{ key }}
          </label>
        </li>
      </ul>
      <h4>String delimiter</h4>
      <ul class="no_bullets">
        <li
          v-for="item in STRING_DELIMITER"
          :key="item"
        >
          <label>
            <input
              type="radio"
              :value="item"
              v-model="delimiters.str"
            />
            {{ item }}
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              v-model="delimiters.str"
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
        :disabled="!delimiters.field"
        @click="emit('submit')"
      >
        Upload
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { FIELD_DELIMITER, STRING_DELIMITER } from '../const/delimiters.js'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const delimiters = defineModel({ type: Object })

const emit = defineEmits(['submit'])
</script>
