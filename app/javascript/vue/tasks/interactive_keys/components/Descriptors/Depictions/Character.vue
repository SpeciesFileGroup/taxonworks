<template>
  <div>
    {{ characterState.name }}
    <input
      type="checkbox"
      :value="characterState.id">
  </div>
</template>

<script>

import { GetCharacterStateDepictions } from '../../../request/resources.js'

export default {
  props: {
    characterState: {
      type: Object,
      required: true
    },
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    selected: {
      get () {
        return this.selected
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      depictions: []
    }
  },
  methods: {
    loadDepictions () {
      GetCharacterStateDepictions(this.characterState.id).then(response => {
        this.depictions = response.body
      })
    }
  }
}
</script>
