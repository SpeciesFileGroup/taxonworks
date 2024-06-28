<template>
  <div
    class="field label-above"
    v-help="help.institution"
  >
    <label
      >Institution (or person responsible for minting this namespace)</label
    >
    <VAutocomplete
      param="term"
      url="/repositories/autocomplete"
      v-model="institution"
      label="label"
      autofocus
      @get-item="setInstitution"
    />
  </div>
</template>

<script setup>
import { vHelp } from '@/directives'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import help from './constants/help'

const institution = defineModel({
  type: String,
  default: undefined
})

function setInstitution({ label }) {
  institution.value = label
}
</script>
