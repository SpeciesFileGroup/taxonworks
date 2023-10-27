<template>
  <div class="field label-above margin-medium-bottom">
    <label>License</label>
    <select v-model="license">
      <option
        v-for="lic in licenses"
        :key="lic.key"
        :value="lic.key"
      >
        <span>{{ lic.label }}</span>
      </option>
    </select>
  </div>
  <div class="field label-above">
    <label>Year</label>
    <input
      type="number"
      v-model="inputYear"
    />
  </div>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import { Attribution } from '@/routes/endpoints'

const props = defineProps({
  modelValue: {
    type: String,
    default: null
  },

  year: {
    type: Number,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue', 'update:year'])

const licenses = ref([])

const license = computed({
  get: () => props.modelValue,
  set(value) {
    emit('update:modelValue', value)
  }
})

const inputYear = computed({
  get: () => props.year,
  set: (value) => emit('update:year', value)
})

onBeforeMount(() => {
  Attribution.licenses().then(({ body }) => {
    licenses.value = Object.entries(body).map(([key, { name, link }]) => ({
      key,
      label: `${name}: ${link}`
    }))

    licenses.value.push({
      key: null,
      label: '-- None --'
    })
  })
})
</script>
