<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content">
      <button
        @click="$emit('update')"
        type="button"
        class="button button-input button-submit margin-medium-right full_width">
        {{ summary.length ? 'Update' : 'Create' }}
      </button>
      <button
        @click="$emit('updateNext', Number(navigate.next))"
        :disabled="!navigate.next"
        type="button"
        class="button button-input button-submit margin-medium-right full_width">
        {{ summary.length ? 'Update' : 'Create' }} and next
      </button>
      <button
        @click="$emit('updateNew')"
        type="button"
        class="button button-input button-submit margin-medium-right full_width">
        {{ summary.length ? 'Update' : 'Create' }} and new
      </button>
      <nuke-component
        :disabled="summary.length === 0"
        class="inline"
        @confirm="updateSled"/>
    </div>
    <ul v-if="sledImage.metadata.length > 0 && summary.length === 0">
      <li v-if="countCO > 0">
        <span>{{countCO}} collection object will be created.</span>
      </li>
      <li v-if="collectionObject.taxon_determinations_attributes.length">
        <span>Taxon determination will be added</span>
      </li>
      <li v-if="identifier.namespace_id && identifier.identifier && sledImage.step_identifier_on">
        <span>Catalogue number will be added.</span>
      </li>
      <li v-if="collectionObject.tags_attributes.length">
        <span>{{ collectionObject.tags_attributes.length }} tags will be added.</span>
      </li>
      <li v-if="collectionObject.notes_attributes.length">
        <span>{{ collectionObject.notes_attributes.length }} notes will be added.</span>
      </li>
      <li v-if="collectionObject.preparation_type_id">
        <span>Preparation type will be added.</span>
      </li>
      <li v-if="collectionObject.repository_id">
        <span>Repository type will be added.</span>
      </li>
      <li v-if="depiction.is_metadata_depiction">
        <span>Depictions will be marked as metadata</span>
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
    navigate () {
      return this.$store.getters[GetterNames.GetNavigation]
    },
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
    depiction () {
      return this.$store.getters[GetterNames.GetDepiction]
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

<style scoped>
  .button-input {
    min-height: 28px;
  }
</style>