<template>
  <div class="field">
    <label
      v-if="headerText"
    >
      {{ headerText }}
    </label>
    <ul class="no_bullets">
      <li
        v-for="item in CURRENT_DETERMINATION_OPTIONS"
        :key="item.value"
      >
        <label>
          <input
            type="radio"
            :value="item.value"
            :name="props.paramName"
            v-model="selectedValue"
          />
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const CURRENT_DETERMINATION_OPTIONS = [
  {
    label: 'Current and historical',
    value: undefined
  },
  {
    label: 'Current only',
    value: true
  },
  {
    label: 'Historical only',
    value: false
  }
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  paramName: {
    type: String,
    required: true
  },

  headerText: {
    type: String,
    default: ''
  }
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const selectedValue = computed({
  get: () => params.value?.[props.paramName],
  set: (value) => {
    if (!params.value) return
    params.value[props.paramName] = value
  }
})

</script>
