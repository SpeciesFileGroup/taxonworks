<template>
  <div>
    <h3>Include</h3>
    <ul class="no_bullets">
      <li
        v-for="({ descendants, ancestors }, label) in options"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :checked="optionValue.ancestors == ancestors && optionValue.descendants == descendants"
            :disabled="!taxonName.length"
            @click="Object.assign(optionValue, { ancestors, descendants })"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },
  taxonName: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const optionValue = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const options = {
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

const params = URLParamsToJSON(location.href)

optionValue.value = {
  descendants: params.descendants,
  ancestors: params.ancestors
}
</script>
