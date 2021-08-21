<template>
  <div class="horizontal-left-content">
    <div
      v-for="(field, index) in fields"
      :key="field.property"
      class="margin-small-right label-above">
      <label class="capitalize">
        {{ field.property }}
      </label>
      <input
        type="text"
        :class="[`input-date-${field.property}`,'input-date']"
        :ref="el => { if (el) fieldsRef[index] = el }"
        :maxlength="field.maxLength"
        :value="props[field.property]"
        @input="autoAdvance($event, index)"
      >
    </div>
  </div>
</template>

<script setup>

import { ref } from 'vue'

const emit = defineEmits(['update:day', 'update:month', 'update:year'])
const fieldsRef = ref([])
const props = defineProps({
  day: [String, Number],
  month: [String, Number],
  year: [String, Number]
})

const fields = [
  {
    property: 'year',
    maxLength: 4
  },
  {
    property: 'month',
    maxLength: 2
  },
  {
    property: 'day',
    maxLength: 2
  }
]

const autoAdvance = (e, index) => {
  const element = fieldsRef.value[index]
  const maxLength = element.getAttribute('maxlength')

  emit(`update:${fields[index].property}`, e.target.value)

  index++

  if (
    element.value.length === Number(maxLength) &&
    fieldsRef.value.length > index
  ) {
    fieldsRef.value[index].focus()
  }
}
</script>
<style scoped>
  .input-date {
    width: 60px;
  }
</style>
