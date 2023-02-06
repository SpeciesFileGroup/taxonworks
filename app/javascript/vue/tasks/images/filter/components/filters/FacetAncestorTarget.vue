<template>
  <label>Target</label>
  <ul class="no_bullets">
    <li
      v-for="(value, key) in OPTIONS"
      :key="key"
    >
      <label>
        <input
          type="radio"
          :value="value"
          v-model="params.taxon_name_id_target"
        />
        {{ key }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { computed, onBeforeMount } from 'vue'

const OPTIONS = {
  All: undefined,
  OTU: 'Otu',
  'Collection object': 'CollectionObject'
}

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

onBeforeMount(() => {
  params.value.taxon_name_id_target = URLParamsToJSON(
    location.href
  ).taxon_name_id_target
})
</script>
