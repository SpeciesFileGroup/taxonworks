<template>
  <div>
    <h3>Nomenclature code</h3>
    <ul class="no_bullets">
      <li
        v-for="option in options">
        <label>
          <input
            :value="option.value"
            v-model="optionValue"
            type="radio">
          {{ option.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data() {
    return {
      options: [
        {
          label: 'Any code',
          value: undefined 
        },
        { 
          label: 'ICZN (animals)',
          value: 'Iczn'
        },
        { 
          label: 'ICN (plants)',
          value: 'Icn'
        },
        { 
          label: 'ICNP (bacteria)',
          value: 'Icnp'
        },
        { 
          label: 'ICTV (viruses)',
          value: 'Ictv'
        }
      ]
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.nomenclature_code
  }
}
</script>
