<template>
  <div>
    <h3>Type</h3>
    <ul class="no_bullets context-menu">
      <li v-for="(item, key) in types">
        <label class="capitalize">
          <input
            v-model="type"
            :value="item"
            type="radio">
          {{ key }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    type: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      types: {
        Any: undefined,
        Bibtex: 'Source::Bibtex',
        Verbatim: 'Source::Verbatim',
        Person: 'Source::Human'
      }
    }
  },

  mounted () {
    this.type = URLParamsToJSON(location.href).source_type
  }
}
</script>
