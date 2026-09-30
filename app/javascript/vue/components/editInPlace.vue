<template>
  <div>
    <div v-if="!editing">
      <span
        v-html="displayLabel"
        v-tooltip="modelValue ? legend : ''"
        @click="setEdit(true)"
      />
    </div>
    <div v-else>
      <input
        ref="inputRef"
        @blur="setEdit(false)"
        @keypress.enter="setEdit(false)"
        v-model="inputField"
        type="text"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, ref, watch } from 'vue'
import { vTooltip } from '@/directives'

const props = defineProps({
  modelValue: {
    type: String
  },

  legend: {
    type: String,
    default: 'Click to edit'
  }
})

const emit = defineEmits(['update:modelValue', 'end'])

const editing = ref(false)
const inputRef = ref(null)

const inputField = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const displayLabel = computed(() => props.modelValue || props.legend)

watch(editing, (newVal) => {
  if (newVal) {
    nextTick(() => {
      inputRef.value.focus()
    })
  } else {
    emit('end', props.modelValue)
  }
})

function setEdit(value) {
  editing.value = value
}
</script>
