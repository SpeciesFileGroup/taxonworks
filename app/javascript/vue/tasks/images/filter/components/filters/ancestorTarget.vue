<template>
  <div>
    <h3>Target</h3>
    <ul class="no_bullets">
      <li v-for="option in options">
        <label>
          <input
            type="radio"
            :value="option.value"
            :disabled="!taxonName.length"
            v-model="optionValue">
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
      type: String,
      default: undefined
    },
    taxonName: {
      type: Array,
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      options: [
        {
          label: 'All',
          value: undefined
        },
        {
          label: 'OTU',
          value: 'Otu'
        },
        {
          label: 'Collection object',
          value: 'CollectionObject'
        }
      ]
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.ancestor_id_target
  }
}
</script>
