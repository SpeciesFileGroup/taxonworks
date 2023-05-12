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
          :disabled="!params.otu_id?.length"
          v-model="otuScope"
        />
        {{ humanize(item) }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed, watch } from 'vue'
import { humanize } from 'helpers/strings'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const includes = [
  'otus',
  'collection_objects',
  'collection_object_observations',
  'otu_observations',
  'type_material',
  'type_material_observations'
]

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const otuScope = computed({
  get: () => props.modelValue.otu_scope || [],
  set: (value) => {
    params.value.otu_scope = value
  }
})

watch(
  () => params.value.otu_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      otuScope.value = []
    }
  }
)
</script>
