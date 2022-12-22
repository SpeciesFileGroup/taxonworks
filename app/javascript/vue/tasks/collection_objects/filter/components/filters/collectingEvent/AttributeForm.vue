<template>
  <div class="horizontal-left-content">
    <div class="field separate-right full_width">
      <label>
        Value
      </label>
      <br>
      <input
        class="full_width"
        :type="TYPES[field.type]"
        v-model="attribute.value"
      >
    </div>
    <div class="field">
      <label>
          &nbsp;
      </label>
      <br>
      <button
        class="button normal-input button-default"
        type="button"
        @click="addField"
      >
        Add
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const TYPES = {
  text: 'text',
  string: 'text',
  integer: 'number',
  decimal: 'number'
}

const props = defineProps({
  field: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['add'])

const attribute = ref({
  exact: false,
  value: undefined
})

const addField = () => {
  emit(
    'add', {
      param: props.field.name,
      ...attribute.value,
      type: props.field.type
    })
}
</script>
