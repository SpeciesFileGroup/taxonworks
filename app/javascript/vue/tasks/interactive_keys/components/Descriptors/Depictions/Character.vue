<template>
  <div >
    <div
      @click="addSelected"
      class="depiction-medium-image"
      :style="{ opacity: characterState.status === 'useless' ? 0.3 : 1 }"
      v-for="depiction in depictions"
      :key="depiction.id">
      <img :src="depiction.image.alternatives.medium.image_file_url"/>
    </div>
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
  created () {
    this.loadDepictions()
  },
  methods: {
    loadDepictions () {
      GetCharacterStateDepictions(this.characterState.id).then(response => {
        this.depictions = response.body
      })
    },

    addSelected () {
      const index = this.selected.findIndex(id => id === this.characterState.id)

      if (index === -1) {
        this.selected.push(this.characterState.id)
      } else {
        this.selected.splice(index, 1)
      }
    }
  }
}
</script>
