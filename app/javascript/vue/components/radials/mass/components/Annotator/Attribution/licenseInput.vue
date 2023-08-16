<template>
  <div>
    <label>License</label>
    <br />
    <select v-model="selectedLicense">
      <option
        v-for="license in licenses"
        :key="license.key"
        :value="license.key"
      >
        <span v-if="license.key != null"> {{ license.key }} : </span>
        {{ license.label }}
      </option>
    </select>
    <VSpinner
      v-if="isLoading"
      legend="Loading licenses..."
    />
  </div>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import { Attribution } from '@/routes/endpoints'
import VSpinner from '@/components/spinner.vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})
const emit = defineEmits(['update:modelValue'])
const selectedLicense = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const licenses = ref([])
const isLoading = ref(true)

onBeforeMount(() => {
  Attribution.licenses()
    .then(({ body }) => {
      licenses.value = [
        ...Object.entries(body).map(([key, label]) => ({ key, label })),
        {
          label: '-- None --',
          key: null
        }
      ]
    })
    .finally((_) => {
      isLoading.value = false
    })
})
</script>
