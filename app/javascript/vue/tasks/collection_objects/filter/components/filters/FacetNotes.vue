<template>
  <div>
    <h3>Notes</h3>
    <div class="field label-above">
      <input 
        class="full_width"
        type="text"
        v-model="params.note_text"
      >
      <label>
        <input
          v-model="params.note_exact"
          type="checkbox">
        Exact
      </label>
    </div>
  </div>
</template>

<script setup>
import { URLParamsToJSON } from 'helpers/url/parse'
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

const {
  note_exact,
  note_text
} = URLParamsToJSON(location.href)

params.value.note_exact = note_exact
params.value.note_text = note_text

</script>
