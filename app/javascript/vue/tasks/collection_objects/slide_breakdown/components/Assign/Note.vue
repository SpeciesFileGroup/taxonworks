<template>
  <fieldset>
    <legend>Note</legend>
    <textarea
      v-model="text"
      class="full_width"
      rows="5">
    </textarea>
    <button
      @click="addNote"
      :disabled="!text"
      class="button normal-input button-submit">
      Add
    </button>
    <list-component
      v-if="collectionObject.notes_attributes.length"
      :list="collectionObject.notes_attributes"
      @delete="removeNote"
      :label="[]"/>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import ListComponent from 'components/displayList'

export default {
  components: {
    ListComponent
  },
  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject)
      }
    }
  },
  data () {
    return {
      text: undefined
    }
  },
  methods: {
    addNote () {
      this.collectionObject.notes_attributes.push(this.text)
      this.text = undefined
    },
    removeNote(note) {
      const index = this.collectionObject.notes_attributes.findIndex(item => { return note === item })
      this.collectionObject.notes_attributes.splice(index, 1)
    }
  }
}
</script>

<style>

</style>