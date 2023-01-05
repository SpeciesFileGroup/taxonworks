<template>
  <FacetContainer>
    <h3 class="capitalize">
      {{ title.replace(/_/g, ' ') }}
    </h3>
    <ul class="no_bullets context-menu">
      <li
        v-for="option in list"
        :key="option.value"
      >
        <label class="capitalize">
          <input
            :value="option.value"
            :name="name"
            v-model="optionValue[param]"
            type="radio"
          >
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed, ref } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  name: {
    type: String,
    default: () => Math.random().toString(36).substr(2, 5)
  },

  title: {
    type: String,
    required: true
  },

  modelValue: {
    type: Object,
    default: () => ({})
  },

  values: {
    type: Array,
    default: () => []
  },

  param: {
    type: String,
    default: undefined
  },

  inverted: {
    type: Boolean,
    default: false
  },

  options: {
    type: Array,
    default: () => [
      {
        label: 'Both',
        value: undefined
      },
      {
        label: 'with',
        value: true
      },
      {
        label: 'without',
        value: false
      }
    ]
  }
})

const emit = defineEmits(['update:modelValue'])

const optionValue = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const list = computed(() =>
  props.inverted
    ? invertedOptions.value
    : props.options
)

const invertedOptions = ref([
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'with',
    value: false
  },
  {
    label: 'without',
    value: true
  }
])

if (props.param) {
  const params = URLParamsToJSON(location.href)
  optionValue.value[props.param] = params[props.param]
}
</script>
