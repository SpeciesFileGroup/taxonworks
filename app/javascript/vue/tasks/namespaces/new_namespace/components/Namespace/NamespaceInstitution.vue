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

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { computed } from 'vue'

export default {
  components: { Autocomplete },

  props: {
    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  setup (props, { emit }) {
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

    return {
      setInstitution,
      institution
    }
  }
}
</script>
