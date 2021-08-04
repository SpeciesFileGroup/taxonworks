<template>
  <div>
    <h3>Citations type</h3>
    <ul class="no_bullets">
      <li v-for="type in types">
        <label class="capitalize">
          <input
            type="checkbox"
            :value="type"
            v-model="citationTypes">
          <span class="capitalize-first-letter">{{ decamelize(type) }}</span>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetCitationTypes } from '../../request/resources'
import Decamelize from 'helpers/decamelize'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: Array,
      default: () => []
    }
  },

  emits: ['update:modelValue'],

  computed: {
    citationTypes: {
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
      types: []
    }
  },

  mounted () {
    GetCitationTypes().then(response => {
      this.types = response.body
    })

    const urlParams = URLParamsToJSON(location.href)
    this.citationTypes = urlParams.citation_object_type ? urlParams.citation_object_type : []
  },

  methods: {
    decamelize: Decamelize
  }
}
</script>
