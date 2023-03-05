<template>
  <div class="field">
    <label>Include</label>
    <ul class="no_bullets">
      <li
        v-for="({ descendants, ancestors }, label) in INCLUDE_OPTIONS"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :checked="params.ancestors == ancestors && params.descendants == descendants"
            :disabled="!params.taxon_name_id?.length"
            @click="Object.assign(params, { ancestors, descendants })"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const INCLUDE_OPTIONS = {
  'N/A': {
    descendants: undefined,
    ancestors: undefined
  },
  Ancestors: {
    descendants: undefined,
    ancestors: true
  },
  Descendants: {
    descendants: true,
    ancestors: undefined
  }
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
