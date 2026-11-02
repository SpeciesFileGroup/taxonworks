<template>
  <div class="flex-col gap-small">
    <div class="horizontal-left-content gap-xsmall">
      <VBtn
        v-for="separator in SEPARATORS"
        :key="separator"
        color="primary"
        @click="emit('select', separator)"
      >
        {{ displaySeparator(separator) }}
      </VBtn>
    </div>
    <div class="horizontal-left-content gap-xsmall">
      <input
        v-model="customSeparator"
        type="text"
        placeholder="Custom"
        @keyup.enter="selectCustom"
      />
      <VBtn
        color="primary"
        medium
        :disabled="!isCustomValid"
        @click="selectCustom"
      >
        Add
      </VBtn>
    </div>
    <span
      v-if="customSeparator && !isCustomValid"
      class="text-sm"
    >
      Separators can't contain letters, numbers, / or :
    </span>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { SEPARATORS } from '../../constants'
import { displaySeparator } from '../../utils/pattern'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['select'])

const customSeparator = ref('')

const isCustomValid = computed(
  () =>
    customSeparator.value.length > 0 &&
    !/[A-Za-z0-9/:]/.test(customSeparator.value)
)

function selectCustom() {
  if (!isCustomValid.value) return

  emit('select', customSeparator.value)
  customSeparator.value = ''
}
</script>
