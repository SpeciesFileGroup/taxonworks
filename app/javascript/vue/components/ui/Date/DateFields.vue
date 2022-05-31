<template>
  <div class="horizontal-left-content align-end">
    <div
      v-for="(field, index) in inputFields"
      :key="field.property"
      class="margin-small-right"
      :class="{ 'label-above': !inline }"
    >
      <label
        v-if="!placeholder"
        :class="{ 'margin-small-right': inline }"
        class="capitalize"
      >
        {{ field.property }}
      </label>
      <input
        :type="field.type"
        :placeholder="placeholder ? field.property : ''"
        :ref="el => { if (el) fieldsRef[index] = el }"
        :maxlength="field.maxLength"
        :value="props[field.property]"
        :step="field.step"
        @input="autoAdvance($event, index)"
      >
    </div>
  </div>
</template>

<script setup>

import { computed, ref } from 'vue'

const props = defineProps({
  day: {
    type: [String, Number],
    default: ''
  },

  month: {
    type: [String, Number],
    default: ''
  },

  year: {
    type: [String, Number],
    default: ''
  },

  time: {
    type: [String, Number],
    default: ''
  },

  placeholder: {
    type: Boolean,
    default: false
  },

  inline: {
    type: Boolean,
    default: false
  },

  timeField: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:day',
  'update:month',
  'update:year',
  'update:time'
])

const dateFields = [
  {
    type: 'text',
    property: 'year',
    maxLength: 4
  },
  {
    type: 'text',
    property: 'month',
    maxLength: 2
  },
  {
    type: 'text',
    property: 'day',
    maxLength: 2
  }
]

const timeField = {
  type: 'time',
  property: 'time',
  step: 2
}

const fieldsRef = ref([])

const inputFields = computed(
  () => props.timeField
    ? [...dateFields, timeField]
    : dateFields
)

const autoAdvance = (e, index) => {
  const element = fieldsRef.value[index]
  const currentField = inputFields.value[index]

  emit(`update:${inputFields.value[index].property}`, e.target.value)

  index++

  if (
    element.value.length === Number(currentField.maxLength) &&
    fieldsRef.value.length > index
  ) {
    fieldsRef.value[index].focus()
  }
}
</script>

<style scoped>
  input[type="text"] {
    width: 60px;
  }
</style>
