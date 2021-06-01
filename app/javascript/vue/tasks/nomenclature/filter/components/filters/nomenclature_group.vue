<template>
  <div>
    <h3>Nomenclature rank</h3>
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
  data () {
    return {
      options: [
        {
          label: 'Any rank',
          value: undefined
        },
        {
          label: 'Higher',
          value: 'Higher'
        },
        { 
          label: 'Family group',
          value: 'Family'
        },
        { 
          label: 'Genus group',
          value: 'Genus'
        },
        { 
          label: 'Species group',
          value: 'Species'
        }
      ]
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.nomenclature_group
  }
}
</script>
