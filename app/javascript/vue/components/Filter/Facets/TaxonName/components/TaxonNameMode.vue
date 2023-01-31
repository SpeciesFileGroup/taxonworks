<template>
  <div class="field">
    <label>Mode</label>
    <ul class="no_bullets">
      <li
        v-for="{ label, value } in MODE_OPTIONS"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :disabled="!params.taxon_name_id?.length"
            :value="value"
            v-model="params.taxon_name_mode"
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  () => props.modelValue.taxon_name_id,
  (newVal, oldVal) => {
    if ((newVal, !oldVal)) {
      params.value.taxon_name_mode = true
    }
  }
)

const MODE_OPTIONS = [
  {
    label: 'And',
    value: true
  },
  {
    label: 'Or',
    value: false
  }
]
</script>
