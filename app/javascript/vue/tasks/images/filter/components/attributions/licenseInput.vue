<template>
  <div>
    <label>License</label>
    <br>
    <select v-model="selectedLicense">
      <option
        v-for="license in licenses"
        :key="license.key"
        :value="license.key">
        <span v-if="license.key != null">
          {{ license.key }} :
        </span>
        {{ license.label }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Attribution } from 'routes/endpoints'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})
const emit = defineEmits(['update:modelValue'])
const selectedLicense = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const licenses = ref([])

Attribution.licenses().then(({ body }) => {
  licenses.value = [
    ...Object.entries(body).map(([key, label]) => ({ key, label })),
    {
      label: '-- None --',
      key: null
    }
  ]
})
</script>
