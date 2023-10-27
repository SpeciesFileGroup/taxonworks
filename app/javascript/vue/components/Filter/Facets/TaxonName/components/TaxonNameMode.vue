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
            :disabled="!isInputEnable"
            :value="value"
            v-model="params.taxon_name_id_mode"
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

const taxonNameId = computed(() => {
  if (!params.value.taxon_name_id) return []

  return Array.isArray(params.value.taxon_name_id)
    ? params.value.taxon_name_id
    : [params.value.taxon_name_id]
})

const isInputEnable = computed(
  () =>
    taxonNameId.value.length ||
    (params.value.subject_taxon_name_id || []).length ||
    (params.value.object_taxon_name_id || []).length
)

watch(isInputEnable, (newVal, oldVal) => {
  if (newVal && !oldVal) {
    params.value.taxon_name_id_mode = true
  }
})

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
