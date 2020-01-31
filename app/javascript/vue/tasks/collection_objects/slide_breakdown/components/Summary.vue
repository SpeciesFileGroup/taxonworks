<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content">
      <button
        @click="$emit('update')"
        type="button"
        class="button normal-input button-submit margin-medium-right full_width">
        {{ summary.length ? 'Update' : 'Create' }}
      </button>
      <button
        type="button"
        class="button normal-input button-submit margin-medium-right full_width">
        {{ summary.length ? 'Update' : 'Create' }} and next
      </button>
      <nuke-component
        :disabled="!sledImage.id"
        class="inline full_width"
        @confirm="updateSled"/>
    </div>
    <ul v-if="sledImage.metadata.length > 0 && summary.length === 0">
      <li v-if="countCO > 0">
        <span>{{countCO}} collection object will be created.</span>
      </li>
      <li v-if="collectionObject.taxon_determinations_attributes.length">
        <span>Taxon determination will be added</span>
      </li>
      <li v-if="identifier.namespace_id && identifier.identifier">
        <span>Catalogue number will be added.</span>
      </li>
    </ul>
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
      return this.$store.getters[GetterNames.GetSledImage].summary
    },
    sledImage: {
      get () {
        return this.$store.getters[GetterNames.GetSledImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSledImage, value)
      }
    },
    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      }
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
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