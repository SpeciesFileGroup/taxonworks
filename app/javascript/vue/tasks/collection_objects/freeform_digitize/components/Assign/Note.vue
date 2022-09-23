<template>
  <fieldset>
    <legend>Note</legend>
    <div class="align-start">
      <textarea
        v-model="text"
        class="full_width margin-small-right"
        rows="5">
      </textarea>
      <lock-component
        v-model="lock.notes_attributes"/>
    </div>
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
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],

  components: { ListComponent },

  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
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

    removeNote (note) {
      const index = this.collectionObject.notes_attributes.findIndex(item => note === item)

      this.collectionObject.notes_attributes.splice(index, 1)
    }
  }
}
</script>
