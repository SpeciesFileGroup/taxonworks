<template>
  <div>
    <div
      @click="addSelected"
      class="depiction-medium-image"
      :style="{ opacity: characterState.status === 'useless' ? 0.3 : 1 }"
      v-for="depiction in depictions"
      :key="depiction.id">
      <img :src="depiction.image.alternatives.medium.image_file_url">
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
    modelValue: {
      type: [Array, String],
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selected: {
      get () {
        return this.modelValue ? Array.isArray(this.modelValue) ? this.modelValue : [this.modelValue] : []
      },
      set (value) {
        this.$emit('update:modelValue', value)
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
