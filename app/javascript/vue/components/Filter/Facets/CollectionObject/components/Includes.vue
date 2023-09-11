<template>
  <h3>Includes</h3>
  <ul class="no_bullets">
    <li
      v-for="item in includes"
      :key="item"
    >
      <label>
        <input
          type="checkbox"
          :value="item"
          :disabled="!params.collection_object_id?.length"
          v-model="coScope"
        />
        {{ humanize(item) }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed, watch } from 'vue'
import { humanize } from '@/helpers/strings'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const includes = ['collection_objects', 'observations', 'collecting_events']

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const coScope = computed({
  get: () => props.modelValue.collection_object_scope || [],
  set: (value) => {
    params.value.collection_object_scope = value
  }
})

watch(
  () => params.value.collection_object_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      coScope.value = []
    }
  }
)
</script>
