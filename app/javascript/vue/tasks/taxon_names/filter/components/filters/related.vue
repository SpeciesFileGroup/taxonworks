<template>
  <div>
    <h3>Include</h3>
    <ul class="no_bullets">
      <li v-for="option in options">
        <label>
          <input
            type="radio"
            :checked="!optionValue.ancestors && !optionValue.descendants"
            :value="option.value"
            v-model="optionValue"
            :disabled="!taxonName.length">
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
      type: Object,
      default: undefined
    },
    taxonName: {
      type: Array,
      required: true
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
          label: 'N/A',
          value: {
            descendants: undefined,
            ancestors: undefined
          }
        },
        {
          label: 'Ancestors',
          value: {
            descendants: undefined,
            ancestors: true
          }
        },
        {
          label: 'Descendants',
          value: {
            descendants: true,
            ancestors: undefined
          }
        }
      ]
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = {
      descendants: params.descendants,
      ancestors: params.ancestors
    }
  }
}
</script>
