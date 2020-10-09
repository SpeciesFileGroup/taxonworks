<template>
  <div class="panel padding-small">
    <label>
      <div
        v-for="depiction in depictions"
        :key="depiction.id">
        <img
          class="full_width"
          :src="depiction.image.alternatives.medium.image_file_url"/>
      </div>
      <input
        type="checkbox"
        :value="characterState.id"
        v-model="selected">
      {{ characterState.name }}
    </label>
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
      type: [Array, String],
      default: undefined
    }
  },
  computed: {
    selected: {
      get () {
        return this.value ? Array.isArray(this.value) ? this.value : [this.value] : []
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
  mounted () {
    this.loadDepictions()
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
