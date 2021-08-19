<template>
  <div class="field label-above">
    <label>Institution (or person responsible for minting this namespace)</label>
    <autocomplete
      param="term"
      url="/repositories/autocomplete"
      v-model="institution"
      label="label"
      @getItem="setInstitution"/>
  </div>
</template>

<script setup>

import { computed, defineProps, defineEmits } from 'vue'
import Autocomplete from 'components/ui/Autocomplete.vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const institution = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const setInstitution = ({ label }) => {
  institution.value = label
}
</script>
