<template>
  <fieldset>
    <legend>Note</legend>
    <div class="align-start">
      <textarea
        v-model="text"
        class="full_width margin-small-right"
        rows="5"
      >
      </textarea>
      <lock-component v-model="lock.notes_attributes" />
    </div>
    <VBtn
      color="primary"
      medium
      :disabled="!text"
      @click="addNote"
    >
      Add
    </VBtn>
    <list-component
      v-if="collectionObject.notes_attributes.length"
      :list="collectionObject.notes_attributes"
      label="text"
      soft-delete
      @delete="removeNote"
    />
  </fieldset>
</template>

<script>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import ListComponent from '@/components/displayList.vue'
import SharedComponent from '../shared/lock.js'
import VBtn from '@/components/ui/VBtn/index.vue'

export default {
  mixins: [SharedComponent],

  components: {
    ListComponent,
    VBtn
  },

  computed: {
    collectionObject: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },

  data() {
    return {
      text: undefined
    }
  },

  methods: {
    addNote() {
      this.collectionObject.notes_attributes.push({ text: this.text })
      this.text = undefined
    },

    removeNote(note) {
      const index = this.collectionObject.notes_attributes.findIndex(
        (item) => note === item
      )

      this.collectionObject.notes_attributes.splice(index, 1)
    }
  }
}
</script>
