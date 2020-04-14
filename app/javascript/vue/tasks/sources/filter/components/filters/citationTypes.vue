<template>
  <div>
    <h2>Citations type</h2>
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

export default {
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    citationTypes: {
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
      types: []
    }
  },
  mounted () {
    GetCitationTypes().then(response => {
      this.types = response.body
    })
  },
  methods: {
    decamelize: Decamelize
  }
}
</script>
