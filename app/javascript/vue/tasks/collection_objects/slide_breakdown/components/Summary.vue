<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content">
      <button
        @click="$emit('update')"
        type="button"
        class="button normal-input button-submit margin-medium-right full_width">
        {{ sledImage.id ? 'Update' : 'Create' }}
      </button>
      <button
        type="button"
        class="button normal-input button-submit margin-medium-right full_width">
        {{ sledImage.id ? 'Update' : 'Create' }} and next
      </button>
      <nuke-component
        :disabled="!sledImage.id"
        class="inline full_width"
        @confirm="updateSled"/>
    </div>
    {{ summary }}
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { MutationNames } from '../store/mutations/mutations'

import NukeComponent from './Nuke'

export default {
  components: {
    NukeComponent
  },
  computed: {
    summary() {
      let sled = this.$store.getters[GetterNames.GetSledImage]
      return sled['summary']
    },
    sledImage: {
      get () {
        return this.$store.getters[GetterNames.GetSledImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSledImage, value)
      }
    },
    countCO () {
      let count = 0
      
      this.sledImage.metadata.forEach(cell => {
        if(cell.metadata == null) {
          count++
        }
      })
      return count
    }
  },
  methods: {
    updateSled () {
      this.$store.dispatch(ActionNames.Nuke)
    },
  }
}
</script>

<style>

</style>