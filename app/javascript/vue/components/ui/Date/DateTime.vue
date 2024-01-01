<template>
  <div class="horizontal-left-content align-end">
    <div
      v-for="(field, index) in dateFields"
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
        v-between-numbers="[field.min, field.max]"
        :type="field.type"
        :placeholder="placeholder ? field.property : ''"
        :ref="
          (el) => {
            if (el) fieldsRef[index] = el
          }
        "
        :maxlength="field.maxLength"
        :value="props[field.property]"
        :step="field.step"
        @input="autoAdvance($event, index)"
        @change="(e) => emit('change', e)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { vBetweenNumbers } from '@/directives/betweenNumbers'

const props = defineProps({
  hour: {
    type: [String, Number],
    default: ''
  },

  minutes: {
    type: [String, Number],
    default: ''
  },

  seconds: {
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
  'update:hour',
  'update:minutes',
  'update:seconds',
  'change',
  'input'
])

const dateFields = [
  {
    type: 'number',
    property: 'hour',
    maxLength: 2,
    min: 0,
    max: 23
  },
  {
    type: 'number',
    property: 'minutes',
    maxLength: 2,
    min: 0,
    max: 59
  },
  {
    type: 'number',
    property: 'seconds',
    maxLength: 2,
    min: 0,
    max: 59
  }
]

const fieldsRef = ref([])

function autoAdvance(e, index) {
  const element = fieldsRef.value[index]
  const currentField = dateFields[index]

  emit(`update:${dateFields[index].property}`, e.target.value)
  emit('input', e)

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
input[type='number'] {
  width: 60px;
}
</style>
