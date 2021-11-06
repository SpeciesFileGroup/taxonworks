<template>
  <div class="horizontal-left-content align-start">
    <div>
      <namespace-institution v-model="namespace.institution"/>
      <div class="field label-above">
        <label>Name</label>
        <input
          v-model="namespace.name"
          id="namespace_name"
          type="text">
      </div>
      <div class="field label-above">
        <label>Short name</label>
        <input
          v-model="namespace.short_name"
          id="namespace_short_name"
          type="text">
      </div>
      <div class="field label-above">
        <label>Verbatim</label>
        <input
          v-model="namespace.verbatim_short_name"
          type="text">
      </div>
      <namespace-delimiter
        :short-name="namespace.short_name"
        v-model="namespace.delimiter"/>
    </div>
  </div>
</template>

<script setup>

import { computed } from 'vue'
import NamespaceInstitution from './NamespaceInstitution.vue'
import NamespaceDelimiter from './NamespaceDelimiter.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const namespace = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

</script>
